"
I am responsible for cursor navigation.

- First I perform all cursor remove operations.
- Then I add new cursors
- and finally perform cursor movement operations
"
Class {
	#name : #AlbTextEditorNavigator,
	#superclass : #AlbTextEditorOperator,
	#instVars : [
		'cursorsToAdd',
		'cursorsToRemove',
		'cursorsToMove',
		'shouldResetDesiredCoordinate',
		'operations',
		'dueTo',
		'shouldHistorize'
	],
	#category : #'Album-Model-Operators'
}

{ #category : #'api - configuration' }
AlbTextEditorNavigator >> add: aCursor [
	"Add a given cursor at the position specified in the added cursor"
	self privateAssertPosition: aCursor position.

	operations add: (AlbTextEditorNavigatorAddCursorOperation cursor: aCursor)
]

{ #category : #'api - configuration' }
AlbTextEditorNavigator >> addAll: aTextEditorCursors [
	aTextEditorCursors do: [ :eachCursor | self add: eachCursor ]
]

{ #category : #'api - configuration' }
AlbTextEditorNavigator >> addAt: aTextPosition [
	"Add a cursor at a given text position"
	self privateAssertPosition: aTextPosition.

	operations add: (AlbTextEditorNavigatorAddCursorOperation cursor: (self privateNewCursorAt: aTextPosition))
]

{ #category : #'api - configuration' }
AlbTextEditorNavigator >> addAtScreenPosition: aScreenPosition [
	"Add a cursor at a given screen position"

	operations add: ((AlbTextEditorNavigatorAddAtScreenPositionOperation cursor: (self privateNewCursorAt: 0)) screenPosition: aScreenPosition)
]

{ #category : #'api - processing' }
AlbTextEditorNavigator >> apply [
	| theCurrentCursors theNewCursors theSameCursors theAddedCursors theRemovedCursors theMovedCursors theCurrentCursorsArray theNewCursorsArray |
	
	cursorsToAdd := Set new.
	cursorsToRemove := Set new.
	cursorsToMove := Dictionary new.

	operations do: [ :anOperation| anOperation performOn: self ].
	
	theCurrentCursors := self cursor allCursors asSet.
	theNewCursors := (self cursor allCursors collect: #copy) asSet.

	self privateRemoveRegisteredIn: theNewCursors.
	self privateAddRegisteredIn: theNewCursors.
	self privateMoveRegisteredIn: theNewCursors.
	
	theSameCursors := theCurrentCursors intersection: theNewCursors.

	theCurrentCursors removeAll: theSameCursors.
	theNewCursors removeAll: theSameCursors.
	
	theCurrentCursorsArray := theCurrentCursors sorted: [ :a :b | a position < b position ].
	theNewCursorsArray := theNewCursors sorted: [ :a :b | a position < b position ].

	theMovedCursors := OrderedCollection new.
	theAddedCursors := OrderedCollection new.
	theRemovedCursors := OrderedCollection new.

	1 to: (theCurrentCursorsArray size max: theNewCursorsArray size) do: [ :anIndex |
		((anIndex <= theCurrentCursorsArray size) and: [ anIndex <= theNewCursorsArray size  ])
			ifTrue: [ theMovedCursors add: (theCurrentCursorsArray at: anIndex) -> (theNewCursorsArray at: anIndex) ]
			ifFalse: [ anIndex > theCurrentCursorsArray size
				ifTrue: [ theAddedCursors add: (theNewCursorsArray at: anIndex) ]
				ifFalse: [ theRemovedCursors add: ((theCurrentCursorsArray at: anIndex)) ] ] ].

	shouldHistorize ifTrue: [
		self editor history
			cursorsMovedFrom: (theRemovedCursors collect: #position), (theMovedCursors collect: [ :anAssociation | anAssociation key position ])
			to: (theAddedCursors collect: #position), (theMovedCursors collect: [ :anAssociation | anAssociation value position ]) ].

	self telemetry
		timeSync: [ 'Remove cursors {1}' format: { theRemovedCursors } ]
		during: [ theRemovedCursors do: [ :aCursor | self privateRemoveCursor: aCursor ] ].
	self telemetry
		timeSync: [ 'Add cursors {1}' format: { theRemovedCursors } ]
		during: [ theAddedCursors do: [ :aCursor | self privateAddCursor: aCursor ] ].
	self telemetry
		timeSync: [ 'Move cursors {1}' format: { theRemovedCursors } ]
		during: [ theMovedCursors do: [ :anAssociation | self privateMoveCursor: anAssociation key to: anAssociation value position ] ].
	
	dueTo := nil
]

{ #category : #accessing }
AlbTextEditorNavigator >> dueTo [
	^ dueTo
]

{ #category : #accessing }
AlbTextEditorNavigator >> dueTo: aTextEditorOperator [
	dueTo := aTextEditorOperator
]

{ #category : #initialization }
AlbTextEditorNavigator >> initialize [
	super initialize.

	operations := OrderedCollection new.
	cursorsToAdd := Set new.
	cursorsToRemove := Set new.
	cursorsToMove := Dictionary new.
	shouldResetDesiredCoordinate := true.
	shouldHistorize := false
]

{ #category : #'api - configuration' }
AlbTextEditorNavigator >> move: aCursor by: aDelta [
	"Move a given cursor by a provided delta"

	operations add: ((AlbTextEditorNavigatorMoveByOperation cursor: aCursor) delta: aDelta)
]

{ #category : #'api - configuration' }
AlbTextEditorNavigator >> move: aCursor to: aTextPosition [
	"Move a given cursor to a provided position"
	self privateAssertPosition: aTextPosition.

	operations add: ((AlbTextEditorNavigatorMoveToOperation cursor: aCursor) position: aTextPosition)
]

{ #category : #'api - configuration' }
AlbTextEditorNavigator >> moveBy: aDelta [
	"Move all cursors by a given delta. The operation is only applied on existing cursor, not the ones that will be added"

	self cursor do: [ :aCursor | operations add: ((AlbTextEditorNavigatorMoveByOperation cursor: aCursor) delta: aDelta) ]
]

{ #category : #'api - configuration' }
AlbTextEditorNavigator >> moveDown [
	"Move all cursors down one line"

	self cursor do: [ :aCursor | operations add: (AlbTextEditorNavigatorMoveDownOperation cursor: aCursor) ]
]

{ #category : #'api - configuration' }
AlbTextEditorNavigator >> moveLeft [
	"Move all cursors to the left"

	self cursor do: [ :aCursor | operations add: (AlbTextEditorNavigatorMoveLeftOperation cursor: aCursor) ]
]

{ #category : #'api - configuration' }
AlbTextEditorNavigator >> moveRight [
	"Move all cursors one to the right"

	self cursor do: [ :aCursor | operations add: (AlbTextEditorNavigatorMoveRightOperation cursor: aCursor) ]
]

{ #category : #'api - configuration' }
AlbTextEditorNavigator >> moveTo: aTextPosition [
	"Move all cursors to a given position (basically, remove all cursors except one)"
	| allCursors |
	self privateAssertPosition: aTextPosition.

	allCursors := self cursor allCursors.
	allCursors allButFirstDo: [ :aCursor | operations add: (AlbTextEditorNavigatorRemoveCursorOperation cursor: aCursor) ].
	
	allCursors
		ifEmpty: [ operations add: (AlbTextEditorNavigatorAddCursorOperation cursor: (self privateNewCursorAt: aTextPosition)) ]
		ifNotEmpty: [ operations add: ((AlbTextEditorNavigatorMoveToOperation cursor: allCursors first) position: aTextPosition) ].
]

{ #category : #'api - configuration' }
AlbTextEditorNavigator >> moveToEndNextWord [
	"Move all cursors to the end of the next word"

	self cursor do: [ :aCursor | operations add: (AlbTextEditorNavigatorMoveToEndNextWordOperation cursor: aCursor) ]
]

{ #category : #'api - configuration' }
AlbTextEditorNavigator >> moveToLineEnd [
	"Move all cursors to the end of their corresponding lines"

	self cursor do: [ :aCursor | operations add: (AlbTextEditorNavigatorMoveToLineEndOperation cursor: aCursor) ]
]

{ #category : #'api - configuration' }
AlbTextEditorNavigator >> moveToLineStart [
	"Move all cursors to the start of their corresponding lines"

	self cursor do: [ :aCursor | operations add: (AlbTextEditorNavigatorMoveToLineStartOperation cursor: aCursor) ]
]

{ #category : #'api - configuration' }
AlbTextEditorNavigator >> moveToScreenPosition: aScreenPosition [
	"Move all cursors to a given screen position (basically, remove all cursors except one)"
	| allCursors |

	allCursors := self cursor allCursors.
	allCursors allButFirstDo: [ :aCursor | operations add: (AlbTextEditorNavigatorRemoveCursorOperation cursor: aCursor) ].
	
	allCursors
		ifEmpty: [ operations add: ((AlbTextEditorNavigatorAddAtScreenPositionOperation cursor: (self privateNewCursorAt: 0)) screenPosition: aScreenPosition) ]
		ifNotEmpty: [ operations add: ((AlbTextEditorNavigatorMoveAtScreenPositionOperation cursor: allCursors first) screenPosition: aScreenPosition) ].
]

{ #category : #'api - configuration' }
AlbTextEditorNavigator >> moveToStartPreviousWord [
	"Move all cursors to the start of the previous word"

	self cursor do: [ :aCursor | operations add: (AlbTextEditorNavigatorMoveToStartPreviousWordOperation cursor: aCursor) ]
]

{ #category : #'api - configuration' }
AlbTextEditorNavigator >> moveUp [
	"Move all cursors up one line"

	self cursor do: [ :aCursor | operations add: (AlbTextEditorNavigatorMoveUpOperation cursor: aCursor) ]
]

{ #category : #'api - configuration' }
AlbTextEditorNavigator >> moveWithin: anInterval [
	"Move all cursors so that they end up within a given text interval.
	The operation is only applied on existing cursor, not the ones that will be added"

	self cursor do: [ :aCursor |
		aCursor position < anInterval first
			ifTrue: [ self move: aCursor to: anInterval first ]
			ifFalse: [ aCursor position > anInterval last
				ifTrue: [ self move: aCursor to: anInterval last ] ] ]
]

{ #category : #notifying }
AlbTextEditorNavigator >> notifyCursorAdded: aCursor [
	self editor dispatchEvent: (AlbTextEditorCursorAddedEvent cursor: aCursor).
	self notifyCursorChanged
]

{ #category : #notifying }
AlbTextEditorNavigator >> notifyCursorChanged [
	self editor dispatchEvent: (AlbTextEditorCursorChangedEvent new cursors: self cursors)
]

{ #category : #private }
AlbTextEditorNavigator >> notifyCursorChanged: aCursor [
	| aCommand |

	aCommand := AlbTextEditorCursorChangeCommand new
		context: self context;
		cursor: aCursor;
		position: aCursor position.
	self editor enqueueCommand: aCommand
]

{ #category : #notifying }
AlbTextEditorNavigator >> notifyCursorMoved: aCursor from: aFromIndex to: aToIndex [
	self editor dispatchEvent: (AlbTextEditorCursorMovedEvent cursor: aCursor from: aFromIndex to: aToIndex dueTo: (dueTo ifNil: [self])).
	self notifyCursorChanged
]

{ #category : #notifying }
AlbTextEditorNavigator >> notifyCursorRemoved: aCursor [
	self editor dispatchEvent: (AlbTextEditorCursorRemovedEvent cursor: aCursor).
	self notifyCursorChanged
]

{ #category : #private }
AlbTextEditorNavigator >> privateAddCursor: aNewCursor [

	self
		assert: [ self cursor allSatisfy: [ :aCursor | aCursor position ~= aNewCursor position ] ]
		description: [ 'Cursor must not exist at a given index' ].
	
	self cursor add: aNewCursor.
	self privateUpdateDesiredCoordinate: aNewCursor.

	self notifyCursorChanged: aNewCursor.
	self notifyCursorAdded: aNewCursor
]

{ #category : #'private - operations' }
AlbTextEditorNavigator >> privateAddRegisteredIn: aSet [
	(cursorsToAdd asSortedCollection: [ :a :b | a position < b position])
		do: [ :aCursor | aSet add: aCursor ]
]

{ #category : #'private - accessing' }
AlbTextEditorNavigator >> privateAssertPosition: aTextPosition [
	self
		assert: [ aTextPosition between: 0 and: self text size ]
		description: [ 'Cursor position ({1}) must be within the interval [0.. {2}]' format: { aTextPosition . self text size } ].
]

{ #category : #'private - accessing' }
AlbTextEditorNavigator >> privateCursorAt: aTextPosition ifFound: aFoundBlock ifNone: aNoneBlock [
	self cursor
		detect: [ :aCursor | aCursor position = aTextPosition ]
		ifFound: aFoundBlock
		ifNone: aNoneBlock
]

{ #category : #private }
AlbTextEditorNavigator >> privateMoveCursor: aCursor to: aTextIndex [
	| anOldCursor |
	self
		assert: [ aCursor position ~= aTextIndex ]
		description: [ 'Can not move a given cursor to the same location' ].
	
	anOldCursor := aCursor copy.
	aCursor position: aTextIndex.
	self privateUpdateDesiredCoordinate: aCursor.

	self telemetry
		timeSync: [ 'Notify cursor changed {1}' format: { anOldCursor position } ]
		during: [ self notifyCursorChanged: anOldCursor ].
		
	self telemetry
		timeSync: [ 'Notify cursor changed {1}' format: { aCursor position } ]
		during: [ self notifyCursorChanged: aCursor ].
		
	self telemetry
		timeSync: [ 'Notify cursor moved from {1} to {2}' format: { anOldCursor position . aTextIndex } ]
		during: [ self notifyCursorMoved: aCursor from: anOldCursor position to: aTextIndex ].
]

{ #category : #'private - operations' }
AlbTextEditorNavigator >> privateMoveRegisteredIn: aSet [
	| theExistingCursors theRequestedCursors theMovableCursors theMergedCursors theRemovedCursor |

	theExistingCursors := (Array streamContents: [ :aStream |
		aSet do: [ :aCursor | aStream nextPut: aCursor ] ]) asSet.
	
	theRequestedCursors := cursorsToMove keys asSet.
	
	"contains existing cursors that should be moved"
	theMovableCursors := theRequestedCursors intersection: theExistingCursors.

	"contains associations newPosition -> cursor, a subset of theMovableCursors"
	theMergedCursors := Dictionary new.

	theMovableCursors do: [ :aCursor |
		| aNewPosition |
		aNewPosition := aCursor position + (cursorsToMove at: aCursor).
		aNewPosition := self privateNormalizePosition: aNewPosition.
		theMergedCursors at: aNewPosition put: aCursor ].
	
	"cursors that should be removed due to merging of moved cursors"
	theRemovedCursor := theRequestedCursors difference: theMergedCursors values.
	
	"remove them now"
	theRemovedCursor do: [ :aCursor | aSet remove: aCursor ].
	
	"cursors that we actually move"
	theMergedCursors keysAndValuesDo: [ :aNewPosition :aCursor |
		self privateUpdateDesiredCoordinate: aCursor.
		aCursor position = aNewPosition
			ifFalse: [ aCursor position: aNewPosition ] ]
]

{ #category : #'private - instance creation' }
AlbTextEditorNavigator >> privateNewCursorAt: aTextPosition [
	"Create a new cursor for a given text position"
	
	^ AlbTextEditorSingleCursor new position: aTextPosition
]

{ #category : #'private - accessing' }
AlbTextEditorNavigator >> privateNormalizePosition: aTextPosition [
	^ (aTextPosition max: 0) min: self text size
]

{ #category : #'private - registration' }
AlbTextEditorNavigator >> privateRegisterForAdd: aCursor [
	cursorsToAdd add: aCursor
]

{ #category : #'private - registration' }
AlbTextEditorNavigator >> privateRegisterForMove: aCursor by: aDelta [
	cursorsToMove at: aCursor put: aDelta
]

{ #category : #'private - registration' }
AlbTextEditorNavigator >> privateRegisterForRemove: aCursor [
	cursorsToRemove add: aCursor
]

{ #category : #private }
AlbTextEditorNavigator >> privateRemoveCursor: aCursorToRemove [
	self
		assert: [ self cursor anySatisfy: [ :aCursor | aCursor position = aCursorToRemove position ] ]
		description: [ 'Cursor must exist at a given index' ].

	self cursor remove: aCursorToRemove.
	self privateUpdateDesiredCoordinate: aCursorToRemove.

	self notifyCursorChanged: aCursorToRemove.
	self notifyCursorRemoved: aCursorToRemove
]

{ #category : #'private - operations' }
AlbTextEditorNavigator >> privateRemoveRegisteredIn: aSet [
	cursorsToRemove do: [ :aCursor | aSet remove: aCursor ]
]

{ #category : #private }
AlbTextEditorNavigator >> privateUpdateDesiredCoordinate: aCursor [
	shouldResetDesiredCoordinate
		ifFalse: [ ^ self ].

	aCursor resetDesiredCoordinate
]

{ #category : #'api - configuration' }
AlbTextEditorNavigator >> remove: aCursor [
	"Remove a given cursor"
	self privateAssertPosition: aCursor position.

	operations add: (AlbTextEditorNavigatorRemoveCursorOperation cursor: aCursor)
]

{ #category : #'api - configuration' }
AlbTextEditorNavigator >> removeAll [
	"Remove all cursors"
	
	self cursor do: [ :aCursor | operations add: (AlbTextEditorNavigatorRemoveCursorOperation cursor: aCursor) ]
]

{ #category : #'api - configuration' }
AlbTextEditorNavigator >> removeAt: aTextPosition [
	"Remove a cursor at a given text position"
	self privateAssertPosition: aTextPosition.

	operations add: (AlbTextEditorNavigatorRemoveCursorOperation cursor: (self privateNewCursorAt: aTextPosition))
]

{ #category : #'api - events' }
AlbTextEditorNavigator >> whenAdded: aBlock [
	"Subscribe to the cursor added event and return an event handler"

	^ self when: AlbTextEditorCursorAddedEvent do: aBlock
]

{ #category : #'api - events' }
AlbTextEditorNavigator >> whenMoved: aBlock [
	"Subscribe to the cursor moved event and return an event handler"

	^ self when: AlbTextEditorCursorMovedEvent do: aBlock
]

{ #category : #'api - events' }
AlbTextEditorNavigator >> whenReachedBoundary: aBlock [
	"Subscribe to the cursor reached boundary event and return an event handler"

	^ self when: AlbTextEditorCursorReachedBoundaryEvent do: aBlock
]

{ #category : #'api - events' }
AlbTextEditorNavigator >> whenRemoved: aBlock [
	"Subscribe to the cursor removed event and return an event handler"

	^ self when: AlbTextEditorCursorRemovedEvent do: aBlock
]

{ #category : #'api - configuration' }
AlbTextEditorNavigator >> withHistorization [
	"Add cursor movement to the history sos that it can be undone / redone"
	
	shouldHistorize := true
]

{ #category : #'api - configuration' }
AlbTextEditorNavigator >> withResettingDesiredCoordinate [
	shouldResetDesiredCoordinate := true
]

{ #category : #'api - configuration' }
AlbTextEditorNavigator >> withoutResettingDesiredCoordinate [
	shouldResetDesiredCoordinate := false
]