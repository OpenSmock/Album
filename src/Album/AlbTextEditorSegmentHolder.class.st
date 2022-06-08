Class {
	#name : #AlbTextEditorSegmentHolder,
	#superclass : #AlbEditorSegmentHolder,
	#category : #'Album-Model-Segment-Text'
}

{ #category : #updating }
AlbTextEditorSegmentHolder >> onCursorChanged [
	"Is sent when text editor's cursor changes.
	Segment holder should update text elements accordingly"
	
	self subclassResponsibility
]

{ #category : #updating }
AlbTextEditorSegmentHolder >> onFocusChanged: aBoolean [
	"Is sent when text editor's focus state changes.
	Segment holder should update text elements accordingly"

	self subclassResponsibility
]

{ #category : #updating }
AlbTextEditorSegmentHolder >> onSelectionChanged [
	"Is sent when text editor's selection changes.
	Segment holder should update text elements accordingly"
	
	self subclassResponsibility
]

{ #category : #updating }
AlbTextEditorSegmentHolder >> onTextChanged [
	"Is sent when text changed in the editor (for example style attributes).
	Segment holder should update text elements accordingly"
	
	self subclassResponsibility
]