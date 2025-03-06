type
  Color* = tuple[r, g, b: uint8]

  Orientation* = enum
    oVertical
    oHorizontal

  Element* = ref object of RootObj
    x*: float = 0.0
    y*: float = 0.0
    width*: float = 1.0
    height*: float = 1.0
    rotation*: float = 0.0
    centered*: bool = false

  ColoredElement* = ref object of Element
    color*: Color

  RectangleElement* = ref object of ColoredElement

  StripesElement* = ref object of Element
    colors*: seq[Color]
    orientation*: Orientation = oVertical

  CircleElement* = ref object of ColoredElement
    radius*: float = 0.5

  EllipseElement* = ref object of ColoredElement
    radiusX*: float = 0.5
    radiusY*: float = 0.5

  DiamondElement* = ref object of ColoredElement

  TextElement* = ref object of ColoredElement
    text*: string
    fontSize*: float = 0.1

  Flag* = object
    name*: string
    proportion*: tuple[vertical, horizontal: uint]
    elements*: seq[Element]
