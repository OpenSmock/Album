Class {
	#name : #AlbExamplesSeeClassSide,
	#superclass : #Object,
	#classVars : [
		'BigString'
	],
	#category : #'Album-Examples-TRY-HERE'
}

{ #category : #accessing }
AlbExamplesSeeClassSide class >> ascent [
	^ -20
]

{ #category : #'editor examples' }
AlbExamplesSeeClassSide class >> bigString [
	"1000000000 is 1Go, ~200 000 pages in LibreOffice - 3 600 000 lines on TextMaker "
	^ BigString ifNil: [ BigString := String loremIpsum: 1000000000 ]
]

{ #category : #'editor examples' }
AlbExamplesSeeClassSide class >> bigStringFromFile [
	" self bigStringFromFile "

	| fref stream |
	fref := 'bigFile.txt' asFileReference.
	fref exists ifFalse: [ self inform: fref fullName, ' does''nt exists' ].
	stream := fref readStream.
	BigString := stream contents.
	stream close
]

{ #category : #'editor examples' }
AlbExamplesSeeClassSide class >> bigStringToFile [
	" self bigStringToFile "

	| fref stream |
	fref := 'bigFile.txt' asFileReference.
	fref deleteIfAbsent: [  ].
	stream := fref writeStream.
	stream nextPutAll: self bigString.
	stream close
]

{ #category : #'editor examples' }
AlbExamplesSeeClassSide class >> cleanUp [ 
	super cleanUp.
	BigString := nil
]

{ #category : #accessing }
AlbExamplesSeeClassSide class >> descent [
	^ 20
]

{ #category : #'editor examples' }
AlbExamplesSeeClassSide class >> embeddedFontsText [

	"
AeFontSlant: normal italic oblique.
AeFontWeight: black bold extraBlack extraBold extraLight light medium normal semiBold semiLight thin
AeFontStretch: condensed expanded extraCondensed extraExpanded normal semiCondensed semiExpanded ultraCondensed ultraExpanded 
"

	| aManager allSlants allWeights allStreches text allChars |
	allChars := 'azertyuiopqsdfghjklmwxcvbn' , String cr , 'AZERTYUIOPQSDFGHJKLMWXCVBN' , String cr , '1234567890'
	            , String cr , '@&é"''[(§è!çà)]-#°_¨*%£+/*.?' , String cr , '~^$`ù=:;,~|'.
	"AeFontManager resetGlobalInstance."
	aManager := AeFontManager globalInstance .
	allSlants := { 
		             BlFontSlant normal.
		             BlFontSlant italic.
		             BlFontSlant oblique }.
	allWeights := { 
		              BlFontWeight normal.
		              BlFontWeight light.
		              BlFontWeight extraLight.
		              BlFontWeight medium.
		              BlFontWeight bold.
		              BlFontWeight semiBold.
		              BlFontWeight extraBold.
		              BlFontWeight black.
		              BlFontWeight extraBlack.
		              BlFontWeight thin }.
	allStreches := { 
		               BlFontStretch normal.
		               BlFontStretch condensed.
		               BlFontStretch semiCondensed.
		               BlFontStretch extraCondensed.
		               BlFontStretch ultraCondensed.
		               BlFontStretch expanded.
		               BlFontStretch semiExpanded.
		               BlFontStretch extraExpanded.
		               BlFontStretch ultraExpanded }.

	text := '' asRopedText.
	aManager familyNames do: [ :fname | 
		allSlants do: [ :slant | 
			allWeights do: [ :weight | 
				allStreches do: [ :strech | 
					(aManager
						 detectFamilyName: fname
						 slant: (AeFontSlant perform: slant name asSymbol)
						 weight: (AeFontWeight perform: weight name asSymbol)
						 stretch: (AeFontStretch perform: strech name asSymbol)
						 ifNone: [  ]) in: [ :face | 
						face ifNotNil: [ 
							| fontBuilder t |
							fontBuilder := BlTextFontAndStyleBuilder new.
							fontBuilder familyName: fname.
							fontBuilder fontSize: 18.
							fontBuilder fontStretch: strech.
							fontBuilder fontWeight: weight.
							fontBuilder fontSlant: slant.
							t := allChars copy asRopedText.
							fontBuilder font applyOnText: t.
							text := text, (String cr , String cr , String cr , fname , ' slant: ' , slant name , ' weight: ' , weight name
							         , ' strech: ' , strech name , ' ' , String cr , String cr) asRopedText , t ] ] ] ] ] ].
	^ text
]

{ #category : #'editor examples' }
AlbExamplesSeeClassSide class >> example_CodeEditorWithRBScannerStylerWithDresser [

	| ed |
	ed := self example_CodeEditorWithRBStylerWithDresser.
	ed viewModel stylerHolder styler: (BlRBScannerTextStyler new fontName: 'Source Code Pro')
]

{ #category : #'editor examples' }
AlbExamplesSeeClassSide class >> example_CodeEditorWithRBStylerWithDresser [

	| text album space vscrollBar |
	text := self methodText asRopedText.

	album := ToAlbum forPharoCode.
	album viewModel text: text.
	"album viewModel fontName: AeFontManager defaultCodeFontFamilyName."
	album viewModel classOrMetaClass: self class.
	album withLineNumbers.
	
	"album editorElement editor inspect."
	"album editorElement selectionView inspect."
	"album editorElement viewModel inspect."
	"album editorElement viewModel stylerHolder inspect."

	"vscrollBar := BlVerticalScrollbarElement new.
	vscrollBar constraintsDo: [ :c | 
		c ignoreByLayout.
		c margin: (BlInsets right: 2).
		c ignored horizontal alignRight.
		c ignored vertical alignBottom ].
	vscrollBar attachTo: album editorElement."
	"album addChild: vscrollBar." 
	space := OBlSpace new.
	space root addChild: album.
	space show.
	^ album


]

{ #category : #'editor examples' }
AlbExamplesSeeClassSide class >> example_EditorAsTextAreaWithDresser [

	| ed space hscrollBar |

	ed := AlbEditorElement new dresser: AlbTextAreaDresser.
	ed viewModel inspect.
	ed constraintsDo: [ :c | 
		c vertical resizer: BlLayoutResizer matchParent. 
		c horizontal resizer: BlLayoutResizer matchParent].
	ed text: ((String loremIpsum: 10000) asRopedText "fontName: 'Source Code Pro'").
	
	hscrollBar := BlHorizontalScrollbarElement new.
	hscrollBar constraintsDo: [ :c |
			c ignoreByLayout.
			c margin: (BlInsets bottom: 2).
			"c ignored vertical alignLeft."
			c ignored vertical alignBottom]. 
	hscrollBar attachTo: ed.
	space := OBlSpace new.
	space root addChild: ed.
	space root addChild: hscrollBar.
	space show.
	^ed
]

{ #category : #'editor examples' }
AlbExamplesSeeClassSide class >> example_EditorAsTextAreaWithHighlight [

	| ed space text |
	ed := AlbEditorElement new.
	text := ('AB', String tab, String tab, 'CD') asRopedText.
	text attribute: (BlTextBackgroundAttribute paint: (Color blue alpha: 0.3)) from: 1 to: 1.
	text attribute: (BlTextBackgroundAttribute paint: (Color yellow alpha: 0.5)) from: 3 to: 6.
	text attribute: (BlTextBackgroundAttribute paint: (Color yellow alpha: 0.5)) from: 2 to: 2.
	text attribute: (BlTextBackgroundAttribute paint: (Color red alpha: 0.3)) from: 3 to: 3.
	text
		fontSize: 24;
		fontName: 'Helvetica Neue'.
	ed text: text.
		"ed inspect."

	space := BlSpace new.
	space root addChild: ed.
	space title: 'editor'.

	space show.
	^ ed
]

{ #category : #'editor examples' }
AlbExamplesSeeClassSide class >> example_EditorAsTextAreaWithoutAnyDresser [

	| ed space |
	ed := AlbEditorElement new.
	"ed withLineNumbers."
	ed text: (String loremIpsum asRopedText).
	space := BlSpace new.
	space root addChild: ed.
	space title: 'editor'.
	"ed inspect."

	space show.
	^ ed
]

{ #category : #'editor examples' }
AlbExamplesSeeClassSide class >> example_EditorPharoChangesText [

	| ed vscrollBar space text |
	" ~4300 pages on LibreOffice, ~8000000 characters "
	text := Smalltalk changesFile readStream contents asRopedText.
	ed := AlbEditorElement forPharoCode dresser: AlbTextAreaDresser new.
	ed text: text.
	ed withoutCacheLimit.
	ed withLineNumbers.
	ed viewModel stylerHolder styler: (BlRBScannerTextStyler new fontName: 'Source Code Pro').
	vscrollBar := BlVerticalScrollbarElement new.
	vscrollBar constraintsDo: [ :c |
			c ignoreByLayout.
			c margin: (BlInsets right: 2).
			c ignored horizontal alignRight.
			c ignored vertical alignBottom]. 
	vscrollBar attachTo: ed.
	space := OBlSpace new.
	space root addChild: ed.
	space root addChild: vscrollBar.
	space show.

]

{ #category : #'editor examples' }
AlbExamplesSeeClassSide class >> example_EditorWithAllFonts [

	"
AeFontSlant: normal italic oblique.
AeFontWeight: black bold extraBlack extraBold extraLight light medium normal semiBold semiLight thin
AeFontStretch: condensed expanded extraCondensed extraExpanded normal semiCondensed semiExpanded ultraCondensed ultraExpanded 
"

	| aManager allSlants allWeights allStreches root text child allChars vscrollBar |
	allChars := 'azertyuiopqsdfghjklmwxcvbn' , String cr , 'AZERTYUIOPQSDFGHJKLMWXCVBN' , String cr , '1234567890'
	            , String cr , '@&é"''(§è!çà)-#°_¨*%£+/.?' , String cr , '€^$`ù=:;,~|'.
	AeFontManager resetGlobalInstance.
	aManager := AeFontManager globalInstance .
	aManager scanEmbeddedFonts.
	aManager scanDefaultDirectories.
	allSlants := { 
		             BlFontSlant normal.
		             BlFontSlant italic.
		             BlFontSlant oblique }.
	allWeights := { 
		              BlFontWeight normal.
		              BlFontWeight light.
		              BlFontWeight extraLight.
		              BlFontWeight medium.
		              BlFontWeight bold.
		              BlFontWeight semiBold.
		              BlFontWeight extraBold.
		              BlFontWeight black.
		              BlFontWeight extraBlack.
		              BlFontWeight thin }.
	allStreches := { 
		               BlFontStretch normal.
		               BlFontStretch condensed.
		               BlFontStretch semiCondensed.
		               BlFontStretch extraCondensed.
		               BlFontStretch ultraCondensed.
		               BlFontStretch expanded.
		               BlFontStretch semiExpanded.
		               BlFontStretch extraExpanded.
		               BlFontStretch ultraExpanded }.

	root := BlElement new constraintsDo: [ :c | 
		        c vertical matchParent.
		        c horizontal matchParent ].
	text := '' asRopedText.
	aManager familyNames do: [ :fname | 
		allSlants do: [ :slant | 
			allWeights do: [ :weight | 
				allStreches do: [ :strech | 
					(aManager
						 detectFamilyName: fname
						 slant: (AeFontSlant perform: slant name asSymbol)
						 weight: (AeFontWeight perform: weight name asSymbol)
						 stretch: (AeFontStretch perform: strech name asSymbol)
						 ifNone: [  ]) in: [ :face | 
						face ifNotNil: [ 
							| fontBuilder t |
							fontBuilder := BlTextFontAndStyleBuilder new.
							fontBuilder familyName: fname.
							fontBuilder fontSize: 18.
							fontBuilder fontStretch: strech.
							fontBuilder fontWeight: weight.
							fontBuilder fontSlant: slant.
							t := allChars copy asRopedText.
							fontBuilder font applyOnText: t.
							text append:
								(String cr , String cr , String cr , fname , ' slant: ' , slant name , ' weight: ' , weight name , ' strech: '
								 , strech name , ' ' , String cr , String cr) asRopedText.
							text append: t ] ] ] ] ] ].
	child := text onAlbum dresser: AlbTextAreaDresser new.
	vscrollBar := BlVerticalScrollbarElement new.
	vscrollBar constraintsDo: [ :c |
			c ignoreByLayout.
			c margin: (BlInsets right: 2).
			c ignored horizontal alignRight.
			c ignored vertical alignBottom]. 
	vscrollBar attachTo: child.
	root addChild: child.
	root addChild: vscrollBar.
	root openInOblSpace
]

{ #category : #'editor examples' }
AlbExamplesSeeClassSide class >> example_EditorWithBigText [

	| ed |
	"The insertion bogue arise around 342225"
	ed := self bigString asRopedText onAlbum.
	"ed constraintsDo: [ :c | 
		c vertical resizer: BlLayoutResizer fitContent. 
		c horizontal resizer: BlLayoutResizer fitContent]."
	"ed inspect."
	ed withLineNumbers.
	ed openInOblSpace
]

{ #category : #'editor examples' }
AlbExamplesSeeClassSide class >> example_EditorWithDynamicAttribute [
"
broken in GlamorousToolKit but what to do with that ?
| cache attribute text ed space |

	cache := Dictionary new.
	
	attribute := BrTextAdornmentDynamicAttribute new
	""beSync;
		beAppend;""
		withCache: cache key: #key;
		stencil: [  {  
			BlElement new
				background: (Color gray alpha: 0.4);
				size: 20@100.
			BlElement new
				background: (Color red alpha: 0.4);
				size: 20@10. } ].

	text := 'Hello >' asRopedText attribute: attribute.
	ed := BrEditor new aptitude: BrGlamorousRegularEditorAptitude new.
	ed constraintsDo: [ :c | 
		c vertical resizer: BlLayoutResizer fitContent. 
		c horizontal resizer: BlLayoutResizer matchParent].

	ed text: text.
	""ed inspect.""
	space := BlSpace new.
	space root addChild: ed.
	space title: 'editor'.
	space show.
	^ text
"
	| cache attribute text ed space |

	cache := Dictionary new.
	
	attribute := AlbTextAdornmentDynamicAttribute new
		beSync;
		"beAppend;"
		stencil: [  {  
			BlElement new
				background: (Color gray alpha: 0.4);
				size: 20@100.
			BlElement new
				background: (Color red alpha: 0.4);
				size: 20@10. } ].

	text := 'Hello >' asRopedText attribute: attribute.
	ed := AlbEditorElement new "dresser: AlbTextAreaDresser new".
	ed constraintsDo: [ :c | 
		c vertical resizer: BlLayoutResizer fitContent. 
		c horizontal resizer: BlLayoutResizer matchParent].

	ed text: text.
	"ed inspect."
	space := OBlSpace new.
	space root addChild: ed.
	space title: 'editor'.
	space show.
	^ text
]

{ #category : #'editor examples' }
AlbExamplesSeeClassSide class >> example_EditorWithEmbeddedFonts [

	"
AeFontSlant: normal italic oblique.
AeFontWeight: black bold extraBlack extraBold extraLight light medium normal semiBold semiLight thin
AeFontStretch: condensed expanded extraCondensed extraExpanded normal semiCondensed semiExpanded ultraCondensed ultraExpanded 
"

	| root text child |
	root := BlElement new constraintsDo: [ :c | 
		        c vertical matchParent.
		        c horizontal matchParent ].
	text := self embeddedFontsText.
	child := text onAlbum dresser: AlbTextAreaDresser new.
	root addChild: child.
	root openInOblSpace
]

{ #category : #'editor examples' }
AlbExamplesSeeClassSide class >> example_EditorWithReplacingAdornment [


	| aText ed |

	aText := ('Hello', String cr, 'World') asRopedText fontSize: 20.
	(aText from: 4 to: 4)
		replacingAdornment: [ BlElement new size: 20@6; background: Color red ].
	ed := aText onAlbum.
	ed withLineNumbers.
	ed openInOblSpace
]

{ #category : #'editor examples' }
AlbExamplesSeeClassSide class >> example_EditorWithSegNumbers [

	| ed t |
	"The insertion bogue arise around 342225"
	"100000000 is ~20 000 pages in LibreOffice - 360 000 lines on TextMaker "
	t := String streamContents: [ :stream | 
		1 to: 400000 do: [ :l | 
			stream << l asString << ': 1234567890'; lf ] ].
	ed := (t asRopedText
		       fontSize: 16) onAlbum.
	ed withLineNumbers.
	ed openInOblSpace
]

{ #category : #'editor examples' }
AlbExamplesSeeClassSide class >> example_EditorWithTGCA [

	| ed tgca tgcaText colorIndex |
	colorIndex := IdentityDictionary new.
	colorIndex at: $T put: (Color red alpha: 0.4).
	colorIndex at: $G put: (Color blue alpha: 0.4).
	colorIndex at: $C put: (Color green alpha: 0.4).
	colorIndex at: $A put: (Color yellow alpha: 0.4).

	"The insertion bogue arise around 342225"
	tgca := self tgcaString.
	tgcaText := '' asRopedText  fontSize: 25.
	tgca linesDo: [ :l | 
		| lrt |
		lrt := l asRopedText.
		l withIndexDo: [ :c :idx | 
			(colorIndex at: c ifAbsent: [  ]) in: [ :color | 
				color ifNotNil: [ lrt attribute: (BlTextBackgroundAttribute paint: color) from: idx to: idx ] ] ].
		tgcaText append: ((lrt , String cr asRopedText) fontName: 'Source Code Pro'; fontSize: 20)].

	ed := tgcaText onAlbum.
	ed dresser: AlbTextAreaDresser new.
	ed constraintsDo: [ :c | 
		c vertical matchParent. 
		c horizontal fitContent].
	"ed inspect."
	ed withLineNumbers.
	ed openInOblSpace
]

{ #category : #elements }
AlbExamplesSeeClassSide class >> example_ExperimentForMultilineLabel [

	| element l |
	l := AlbTextScissor new cut: String loremIpsum asRopedText.

	element := BlElement new
		           layout: AlbLineFlowLayout new;
		           constraintsDo: [ :c | 
			           c horizontal matchParent.
			           c vertical fitContent ];
		           addChildren: (l collect: [ :w | w asElement editorMeasurement ]).
	element openInOBlSpace
]

{ #category : #elements }
AlbExamplesSeeClassSide class >> example_ExperimentForMultilineLabel0 [

	| element l |
	l := AlbTextScissor new cut: ('This is a text' asRopedText fontSize: 20).

	element := BlElement new
		           layout: AlbLineFlowLayout new;
		           constraintsDo: [ :c | 
			           c horizontal matchParent.
			           c vertical fitContent ];
		           addChildren: (l collect: [ :w | w asElement editorMeasurement ]).
	element border: (BlBorder paint: Color gray width: 1).
	element inspect.
	element openInOBlSpace
]

{ #category : #elements }
AlbExamplesSeeClassSide class >> example_ExperimentForMultilineLabel2 [

	| element l |
	l := AlbTextScissor new cut: (('Default font and size' asRopedText, ('Source code pro 40 bold' asRopedText fontSize: 40; fontName: 'Source code pro'; bold) 
	 , (' Default font 30' asRopedText fontSize: 30))).

	element := BlElement new
		           layout: AlbLineFlowLayout new;
		           constraintsDo: [ :c | 
			           c horizontal matchParent.
			           c vertical fitContent ];
		           addChildren: (l collect: [ :w | w asElement editorMeasurement ]).
	element openInOBlSpace
]

{ #category : #elements }
AlbExamplesSeeClassSide class >> example_ExperimentForMultilineLabel3 [

	| root text itor |
	text := 'Default font and size' asRopedText , String cr asRopedText , ('Source code pro 40 bold' asRopedText
		         fontSize: 40;
		         fontName: 'Source code pro';
		         bold) , String cr asRopedText , (' Default font 30' asRopedText fontSize: 30).

	root := BlElement new
		        constraintsDo: [ :c | 
			        c vertical matchParent.
			        c horizontal matchParent ];
		        layout: BlLinearLayout vertical.

	itor := text iterator.
	[ itor hasNext ] whileTrue: [ 
		itor nextLineIndicesDo: [ :aLineStart :aLineEnd :aLineDelimiterEnd | 
			| sub cutted lineElement |
			sub := text from: aLineStart to: aLineEnd.
			cutted := AlbTextScissor new cut: sub.
			lineElement := BlElement new
				               layout: AlbLineFlowLayout new;
				               constraintsDo: [ :c | 
					               c horizontal matchParent.
					               c vertical fitContent ];
				               addChildren: (cutted collect: [ :w | w asElement editorMeasurement ]).
			root addChild: lineElement ] ].

	root openInOBlSpace
]

{ #category : #elements }
AlbExamplesSeeClassSide class >> example_ExperimentForMultilineLabel4 [

	| root text itor |
	text := self embeddedFontsText.

	root := BlElement new
		        constraintsDo: [ :c | 
			        c vertical matchParent.
			        c horizontal matchParent ];
		        layout: BlLinearLayout vertical.
	itor := text iterator.
	[ itor hasNext ] whileTrue: [ 
		itor nextLineIndicesDo: [ :aLineStart :aLineEnd :aLineDelimiterEnd | 
			| sub cutted lineElement |
			sub := text from: aLineStart to: aLineEnd.
			cutted := AlbTextScissor new cut: sub.
			cutted ifEmpty: [ 
				cutted := Array with:
					          (BlText empty attributes: sub iterator attributes) ].
			lineElement := BlElement new
				               layout: AlbLineFlowLayout new;
				               constraintsDo: [ :c | 
					               c horizontal matchParent.
					               c vertical fitContent ];
				               addChildren:
					               (cutted collect: [ :w | 
							                w asElement editorMeasurement ]).
			root addChild: lineElement ] ].

	root openInOBlSpace
]

{ #category : #elements }
AlbExamplesSeeClassSide class >> example_ExperimentForMultilineLabel5 [

	| root text itor |
	text := self embeddedFontsText.

	root := BlElement new
		        constraintsDo: [ :c | 
			        c vertical matchParent.
			        c horizontal matchParent ];
		        layout: BlLinearLayout vertical alignTopCenter.
	itor := text iterator.
	[ itor hasNext ] whileTrue: [ 
		itor nextLineIndicesDo: [ :aLineStart :aLineEnd :aLineDelimiterEnd | 
			| sub cutted lineElement |
			sub := text from: aLineStart to: aLineEnd.
			cutted := AlbTextScissor new cut: sub.
			cutted ifEmpty: [ 
				cutted := Array with:
					          (BlText empty attributes: sub iterator attributes) ].
			lineElement := BlElement new
				               layout: AlbLineFlowLayout new;
				               constraintsDo: [ :c | 
					               c horizontal fitContent.
					               c vertical fitContent ];
				               addChildren:
					               (cutted collect: [ :w | 
							                w asElement editorMeasurement ]).
			"lineElement constraintsDo: [ :c | c linear horizontal alignCenter ]."
			root addChild: lineElement ] ].

	root openInOBlSpace
]

{ #category : #'editor examples' }
AlbExamplesSeeClassSide class >> example_RopedTextWithDifferentFontSize [

	(' Default font and size' asRopedText
	 , (' ( Source code pro 40 bold ) ' asRopedText fontSize: 40; fontName: 'Source code pro'; bold) 
	 , (' Default font 30' asRopedText fontSize: 30)) onAlbum
		withLineNumbers;
		"inspect"
		openInOblSpace 
]

{ #category : #elements }
AlbExamplesSeeClassSide class >> example_ScaledElement [

	| content scalable |
	content := BlElement new
		           size: 20 @ 20;
		           background: Color red.

	scalable := BlScalableElement new.
	
	scalable scaleStrategy: (BlScalableFixedStrategy zoom: 10). "set custom zoom level"
	"scalable scaleStrategy: BlScalableFitWidthStrategy new." "Fit horizontally"
	"scalable scaleStrategy: BlScalableFitHeightStrategy new. ""Fit vertically""
	scalable scaleStrategy: BlScalableFitAllStrategy new. ""Fit vertically and horizontally at the same time"""
	scalable constraintsDo: [ :c | 
		c horizontal matchParent .
		c vertical matchParent ].
	content border: (BlBorder paint: Color blue width: 2).
	scalable contentElement: content.
	scalable border: (BlBorder paint: Color yellow width: 5).
	scalable outskirts: BlOutskirts inside.
	scalable openInOBlSpace
]

{ #category : #elements }
AlbExamplesSeeClassSide class >> example_TextFlowWithAnimatedZoomableElements [

	| element |
	element := BlElement new
		           layout: (AlbLineFlowLayout new lineSpacing: 10);
		           constraintsDo: [ :c | 
			           c horizontal matchParent.
			           c vertical matchParent ];
		           addChildren: (20 timesCollect: [ 
					            | e zoomable anim |
					            anim := BlSequentialAnimation withAll: { 
								                    (BlTransformAnimation new
									                     absolute;
									                     duration: 1 seconds;
									                     in: [ :elem | 
										                     elem transform
											                     scaleBy: 10@10;
											                     apply ];
									                     yourself).
								                    (BlTransformAnimation new
									                     absolute;
									                     duration: 2 seconds;
									                     in: [ :elem | 
										                     elem transform
											                     scaleBy: 0.5 asPoint;
											                     apply ];
									                     yourself) }.
					            anim beInfinite.
					            e := BlElement new
						                 size: 10 @ 10;
						                 margin: (BlInsets all: 1);
						                 background: (Color random alpha: 0.5).
					            zoomable := BlZoomableElement new.
					            zoomable constraintsDo: [ :c | 
						            c horizontal fitContent.
						            c vertical fitContent ].
					            zoomable zoomLevel: 10.
					            zoomable border: (BlBorder paint: Color gray width: 1).
					            zoomable addChild: e.
					            e addAnimation: anim.
					            zoomable ]).
	element openInNewSpace
]

{ #category : #elements }
AlbExamplesSeeClassSide class >> example_TextFlowWithBlElements [

	| element |
	element := BlElement new
		           layout: (AlbLineFlowLayout new lineSpacing: 10);
		           constraintsDo: [ :c | 
							c minWidth: 50.
			           c horizontal matchParent.
			           c vertical matchParent ];
		           addChildren: (20 timesCollect: [ 
					            | anAnimation |
					            anAnimation := BlSequentialAnimation new.
					            anAnimation add:
							            (BlTransformAnimation scale: 2) absolute.
					            anAnimation add:
							            (BlTransformAnimation scale: 0.5) absolute.
					            anAnimation beInfinite.
					            BlElement new
						            size: 50 @ 20;
						            margin: (BlInsets all: 4);
						            background: (Color random alpha: 0.5);
						            addAnimation: anAnimation ]).
	element openInOBlSpace
]

{ #category : #'editor examples' }
AlbExamplesSeeClassSide class >> example_WithClickAndHoverAttributes [

	| text styler editorElement space clickText hoverText |
	self flag: 'Works, but should be revised because the implementaion of these attributes in Album is really crappy'.
	clickText := '	<Clik here>'.
	hoverText := '<<<Mouse over here >>>'.
	text := (clickText , ' ' , hoverText) asRopedText.
	editorElement := AlbEditorElement new text: text.

	"editorElement editorText
		attributes: { 
				(BlTextBackgroundAttribute new paint: Color lightBlue).
				(AlbTextEventHandlerAttribute new when: BlClickEvent do: [ :anEvent | self inform: anEvent asString. anEvent consumed: true ]) }
		from: 3
		to: 11."

"	editorElement editorText
		attributes: { 
				(BlTextBackgroundAttribute new paint: Color yellow).
				(AlbTextEventHandlerAttribute new
					 when: BlMouseEnterEvent do: [ :anEvent | self inform: anEvent asString. anEvent consumed: true ];
					 when: BlMouseLeaveEvent do: [ :anEvent | self inform: anEvent asString. anEvent consumed: true ]) }
		from: 17
		to: 30."

	space := BlSpace new.
	space root addChild: editorElement.
	space show
]

{ #category : #'editor examples' }
AlbExamplesSeeClassSide class >> example_WithCrLfOnly [

	| ed space |
	ed := AlbEditorElement new text: String crlf.
	ed editor segmentCollector inspect.
	ed withLineNumbers.
	space := BlSpace new.
	space root addChild: ed.
	space show
]

{ #category : #'editor examples' }
AlbExamplesSeeClassSide class >> example_WithCrOnly [

	| ed space |
	ed := AlbEditorElement new text: String cr.
	ed editor segmentCollector inspect.
	ed withLineNumbers.
	space := BlSpace new.
	space root addChild: ed.
	space show
]

{ #category : #'editor examples' }
AlbExamplesSeeClassSide class >> example_WithCrWithCrLf [

	| ed space |
	ed := AlbEditorElement new text: 'Before Cr', String cr, 'Before CrLf', String crlf, 'After'.
	ed withLineNumbers.
	space := BlSpace new.
	space root addChild: ed.
	space show
]

{ #category : #'editor examples' }
AlbExamplesSeeClassSide class >> example_WithEmptyText [

	| ed space |
	ed := AlbEditorElement new.
	space := BlSpace new.
	space root addChild: ed.
	space show
]

{ #category : #'editor examples' }
AlbExamplesSeeClassSide class >> example_WithEmptyTextFitContents [

	| ed space |
	ed := AlbEditorElement new dresser: AlbTextAreaDresser new.
	ed constraintsDo: [ :c | 
		c horizontal fitContent.
		c vertical fitContent ].
	space := BlSpace new.
	space root addChild: ed.
	space show
]

{ #category : #'editor examples' }
AlbExamplesSeeClassSide class >> example_WithHelloWorld [

	| ed space text editor |
	text := ('Hello World') asRopedText fontSize: 40.
	editor := AlbTextEditor new text: text.
	ed := AlbEditorElement new.
	ed withLineNumbers.
	ed editor: editor.
	space := BlSpace new.
	space root addChild: ed.
	space show
]

{ #category : #elements }
AlbExamplesSeeClassSide class >> example_elements_sandbox [

	| sp root child1 child2 |
	root := BlElement new background: Color cyan.
	child1 := BlElement new background: Color yellow.
	child2 := BlElement new background: Color gray.
	root layout: BlFlowLayout new.
	root addChild: child1.
	root addChild: child2.
	root constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ].
	sp := OBlSpace new.
	sp addChild: root.
	sp show
]

{ #category : #'instance creation' }
AlbExamplesSeeClassSide class >> glyphHeight [
	^ self ascent abs + self descent
]

{ #category : #'instance creation' }
AlbExamplesSeeClassSide class >> glyphWidth [
	^ 30
]

{ #category : #'instance creation' }
AlbExamplesSeeClassSide class >> lineSpacing [
	^ 5
]

{ #category : #accessing }
AlbExamplesSeeClassSide class >> methodText [
	^ self  class sourceCodeAt: #example_CodeEditorWithRBStylerWithDresser
]

{ #category : #'instance creation' }
AlbExamplesSeeClassSide class >> paragraphMargin [
	^ BlInsets all: 15
]

{ #category : #'editor examples' }
AlbExamplesSeeClassSide class >> tgcaString [
	^ 'ATTAAAGGTTTATACCTTCCCAGGTAACAAACCAACCAACTTTCGATCTCTTGTAGATCTGTTCTCTAAACGAACTT
AACATAGCAGTGGTGTTACCCGTGAACTCATGCGTGAGCTTAACGGAGGGGCATACACTCGCTATGTCGATAACAAC
TTCTGTGGCCCTGATGTAAAATCTGTGTGGCTGTCACTCGGCTGCATGCTTAGTGCACTCACGCAGTATAATTAATA
ACTAATTACTGTCGTTGACAGGACACGAGTAACTCGTCTATCTTCTGCAGGCTGCTTACGGTTTCGTCCGTGTTGCA
GCCGATCATCAGCACATCTAGGTTTCGTCCGGGTGTGACCGAAAGGTAAGATGGAGAGCCTTGTCCCTGGTTTCAAC
GAGAAAACACACGTCCAACTCAGTTTGCCTGTTTTACAGGTTCGCGACGTGCTCGTACGTGGCTTTGGAGACTCCGT
GGAGGAGGTCTTATCAGAGGCACGTCAACATCTTAAAGATGGCACTTGTGGCTTAGTAGAAGTTGAAAAAGGCGTTT
ATTAAAGGTTTATACCTTCCCAGGTAACAAACCAACCAACTTTCGATCTCTTGTAGATCTGTTCTCTAAACGAACTT
AACATAGCAGTGGTGTTACCCGTGAACTCATGCGTGAGCTTAACGGAGGGGCATACACTCGCTATGTCGATAACAAC
TTCTGTGGCCCTGATGTAAAATCTGTGTGGCTGTCACTCGGCTGCATGCTTAGTGCACTCACGCAGTATAATTAATA
ACTAATTACTGTCGTTGACAGGACACGAGTAACTCGTCTATCTTCTGCAGGCTGCTTACGGTTTCGTCCGTGTTGCA
GCCGATCATCAGCACATCTAGGTTTCGTCCGGGTGTGACCGAAAGGTAAGATGGAGAGCCTTGTCCCTGGTTTCAAC
GAGAAAACACACGTCCAACTCAGTTTGCCTGTTTTACAGGTTCGCGACGTGCTCGTACGTGGCTTTGGAGACTCCGT
GGAGGAGGTCTTATCAGAGGCACGTCAACATCTTAAAGATGGCACTTGTGGCTTAGTAGAAGTTGAAAAAGGCGTTT
ATTAAAGGTTTATACCTTCCCAGGTAACAAACCAACCAACTTTCGATCTCTTGTAGATCTGTTCTCTAAACGAACTT
AACATAGCAGTGGTGTTACCCGTGAACTCATGCGTGAGCTTAACGGAGGGGCATACACTCGCTATGTCGATAACAAC
TTCTGTGGCCCTGATGTAAAATCTGTGTGGCTGTCACTCGGCTGCATGCTTAGTGCACTCACGCAGTATAATTAATA
ACTAATTACTGTCGTTGACAGGACACGAGTAACTCGTCTATCTTCTGCAGGCTGCTTACGGTTTCGTCCGTGTTGCA
GCCGATCATCAGCACATCTAGGTTTCGTCCGGGTGTGACCGAAAGGTAAGATGGAGAGCCTTGTCCCTGGTTTCAAC
GAGAAAACACACGTCCAACTCAGTTTGCCTGTTTTACAGGTTCGCGACGTGCTCGTACGTGGCTTTGGAGACTCCGT
GGAGGAGGTCTTATCAGAGGCACGTCAACATCTTAAAGATGGCACTTGTGGCTTAGTAGAAGTTGAAAAAGGCGTTT
ATTAAAGGTTTATACCTTCCCAGGTAACAAACCAACCAACTTTCGATCTCTTGTAGATCTGTTCTCTAAACGAACTT
AACATAGCAGTGGTGTTACCCGTGAACTCATGCGTGAGCTTAACGGAGGGGCATACACTCGCTATGTCGATAACAAC
TTCTGTGGCCCTGATGTAAAATCTGTGTGGCTGTCACTCGGCTGCATGCTTAGTGCACTCACGCAGTATAATTAATA
ACTAATTACTGTCGTTGACAGGACACGAGTAACTCGTCTATCTTCTGCAGGCTGCTTACGGTTTCGTCCGTGTTGCA
GCCGATCATCAGCACATCTAGGTTTCGTCCGGGTGTGACCGAAAGGTAAGATGGAGAGCCTTGTCCCTGGTTTCAAC
GAGAAAACACACGTCCAACTCAGTTTGCCTGTTTTACAGGTTCGCGACGTGCTCGTACGTGGCTTTGGAGACTCCGT
GGAGGAGGTCTTATCAGAGGCACGTCAACATCTTAAAGATGGCACTTGTGGCTTAGTAGAAGTTGAAAAAGGCGTTT
ATTAAAGGTTTATACCTTCCCAGGTAACAAACCAACCAACTTTCGATCTCTTGTAGATCTGTTCTCTAAACGAACTT
AACATAGCAGTGGTGTTACCCGTGAACTCATGCGTGAGCTTAACGGAGGGGCATACACTCGCTATGTCGATAACAAC
TTCTGTGGCCCTGATGTAAAATCTGTGTGGCTGTCACTCGGCTGCATGCTTAGTGCACTCACGCAGTATAATTAATA
ACTAATTACTGTCGTTGACAGGACACGAGTAACTCGTCTATCTTCTGCAGGCTGCTTACGGTTTCGTCCGTGTTGCA
GCCGATCATCAGCACATCTAGGTTTCGTCCGGGTGTGACCGAAAGGTAAGATGGAGAGCCTTGTCCCTGGTTTCAAC
GAGAAAACACACGTCCAACTCAGTTTGCCTGTTTTACAGGTTCGCGACGTGCTCGTACGTGGCTTTGGAGACTCCGT
GGAGGAGGTCTTATCAGAGGCACGTCAACATCTTAAAGATGGCACTTGTGGCTTAGTAGAAGTTGAAAAAGGCGTTT
ATTAAAGGTTTATACCTTCCCAGGTAACAAACCAACCAACTTTCGATCTCTTGTAGATCTGTTCTCTAAACGAACTT
AACATAGCAGTGGTGTTACCCGTGAACTCATGCGTGAGCTTAACGGAGGGGCATACACTCGCTATGTCGATAACAAC
TTCTGTGGCCCTGATGTAAAATCTGTGTGGCTGTCACTCGGCTGCATGCTTAGTGCACTCACGCAGTATAATTAATA
ACTAATTACTGTCGTTGACAGGACACGAGTAACTCGTCTATCTTCTGCAGGCTGCTTACGGTTTCGTCCGTGTTGCA
GCCGATCATCAGCACATCTAGGTTTCGTCCGGGTGTGACCGAAAGGTAAGATGGAGAGCCTTGTCCCTGGTTTCAAC
GAGAAAACACACGTCCAACTCAGTTTGCCTGTTTTACAGGTTCGCGACGTGCTCGTACGTGGCTTTGGAGACTCCGT
GGAGGAGGTCTTATCAGAGGCACGTCAACATCTTAAAGATGGCACTTGTGGCTTAGTAGAAGTTGAAAAAGGCGTTT
ATTAAAGGTTTATACCTTCCCAGGTAACAAACCAACCAACTTTCGATCTCTTGTAGATCTGTTCTCTAAACGAACTT
AACATAGCAGTGGTGTTACCCGTGAACTCATGCGTGAGCTTAACGGAGGGGCATACACTCGCTATGTCGATAACAAC
TTCTGTGGCCCTGATGTAAAATCTGTGTGGCTGTCACTCGGCTGCATGCTTAGTGCACTCACGCAGTATAATTAATA
ACTAATTACTGTCGTTGACAGGACACGAGTAACTCGTCTATCTTCTGCAGGCTGCTTACGGTTTCGTCCGTGTTGCA
GCCGATCATCAGCACATCTAGGTTTCGTCCGGGTGTGACCGAAAGGTAAGATGGAGAGCCTTGTCCCTGGTTTCAAC
GAGAAAACACACGTCCAACTCAGTTTGCCTGTTTTACAGGTTCGCGACGTGCTCGTACGTGGCTTTGGAGACTCCGT
GGAGGAGGTCTTATCAGAGGCACGTCAACATCTTAAAGATGGCACTTGTGGCTTAGTAGAAGTTGAAAAAGGCGTTT
ATTAAAGGTTTATACCTTCCCAGGTAACAAACCAACCAACTTTCGATCTCTTGTAGATCTGTTCTCTAAACGAACTT
AACATAGCAGTGGTGTTACCCGTGAACTCATGCGTGAGCTTAACGGAGGGGCATACACTCGCTATGTCGATAACAAC
TTCTGTGGCCCTGATGTAAAATCTGTGTGGCTGTCACTCGGCTGCATGCTTAGTGCACTCACGCAGTATAATTAATA
ACTAATTACTGTCGTTGACAGGACACGAGTAACTCGTCTATCTTCTGCAGGCTGCTTACGGTTTCGTCCGTGTTGCA
GCCGATCATCAGCACATCTAGGTTTCGTCCGGGTGTGACCGAAAGGTAAGATGGAGAGCCTTGTCCCTGGTTTCAAC
GAGAAAACACACGTCCAACTCAGTTTGCCTGTTTTACAGGTTCGCGACGTGCTCGTACGTGGCTTTGGAGACTCCGT
GGAGGAGGTCTTATCAGAGGCACGTCAACATCTTAAAGATGGCACTTGTGGCTTAGTAGAAGTTGAAAAAGGCGTTT
ATTAAAGGTTTATACCTTCCCAGGTAACAAACCAACCAACTTTCGATCTCTTGTAGATCTGTTCTCTAAACGAACTT
AACATAGCAGTGGTGTTACCCGTGAACTCATGCGTGAGCTTAACGGAGGGGCATACACTCGCTATGTCGATAACAAC
TTCTGTGGCCCTGATGTAAAATCTGTGTGGCTGTCACTCGGCTGCATGCTTAGTGCACTCACGCAGTATAATTAATA
ACTAATTACTGTCGTTGACAGGACACGAGTAACTCGTCTATCTTCTGCAGGCTGCTTACGGTTTCGTCCGTGTTGCA
GCCGATCATCAGCACATCTAGGTTTCGTCCGGGTGTGACCGAAAGGTAAGATGGAGAGCCTTGTCCCTGGTTTCAAC
GAGAAAACACACGTCCAACTCAGTTTGCCTGTTTTACAGGTTCGCGACGTGCTCGTACGTGGCTTTGGAGACTCCGT
GGAGGAGGTCTTATCAGAGGCACGTCAACATCTTAAAGATGGCACTTGTGGCTTAGTAGAAGTTGAAAAAGGCGTTT
ATTAAAGGTTTATACCTTCCCAGGTAACAAACCAACCAACTTTCGATCTCTTGTAGATCTGTTCTCTAAACGAACTT
AACATAGCAGTGGTGTTACCCGTGAACTCATGCGTGAGCTTAACGGAGGGGCATACACTCGCTATGTCGATAACAAC
TTCTGTGGCCCTGATGTAAAATCTGTGTGGCTGTCACTCGGCTGCATGCTTAGTGCACTCACGCAGTATAATTAATA
ACTAATTACTGTCGTTGACAGGACACGAGTAACTCGTCTATCTTCTGCAGGCTGCTTACGGTTTCGTCCGTGTTGCA
GCCGATCATCAGCACATCTAGGTTTCGTCCGGGTGTGACCGAAAGGTAAGATGGAGAGCCTTGTCCCTGGTTTCAAC
GAGAAAACACACGTCCAACTCAGTTTGCCTGTTTTACAGGTTCGCGACGTGCTCGTACGTGGCTTTGGAGACTCCGT
GGAGGAGGTCTTATCAGAGGCACGTCAACATCTTAAAGATGGCACTTGTGGCTTAGTAGAAGTTGAAAAAGGCGTTT'
]

{ #category : #'instance creation' }
AlbExamplesSeeClassSide class >> wordPadding [
	^ BlInsets top: 3 bottom: 3
]