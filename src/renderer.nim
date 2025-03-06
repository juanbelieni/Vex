import flag
import std/strutils
import std/strformat
import std/math

func toHex*(color: Color): string =
  result = "#" & toHex(color.r, 2) & toHex(color.g, 2) & toHex(color.b, 2)

proc renderElement*(element: Element, width, height: float): string =
  var
    x = element.x * width
    y = element.y * height
    w = element.width * width
    h = element.height * height
    rotation = element.rotation
    cx = x + w / 2
    cy = y + h / 2

  if element.centered:
    x += width / 2 - w / 2
    y += height / 2 - h / 2

  if element of RectangleElement:
    let element = RectangleElement(element)
    result =
      fmt"""<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{element.color.toHex()}" transform="rotate({rotation} {cx} {cy})" />""" &
      "\n"
  elif element of StripesElement:
    let element = StripesElement(element)
    result = fmt"""<g transform="rotate({rotation} {cx} {cy})">""" & "\n"
    let stripeCount = element.colors.len.float
    if element.orientation == oVertical:
      let stripeWidth = w / stripeCount
      for i, color in element.colors:
        let
          x = x + i.float * stripeWidth
          y = y
          w = stripeWidth
          h = h
        result &=
          fmt"""<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{color.toHex()}" />""" &
          "\n"
    else:
      let stripeHeight = h / stripeCount
      for i, color in element.colors:
        let
          x = x
          y = y + i.float * stripeHeight
          w = w
          h = stripeHeight
        result &=
          fmt"""<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{color.toHex()}" />""" &
          "\n"
    result &= "</g>" & "\n"
  elif element of CircleElement:
    let element = CircleElement(element)
    var
      cx = element.x * width
      cy = element.y * height
      r = element.radius * min(width, height)
    if element.centered:
      cx += width / 2
      cy += height / 2
    result =
      fmt"""<circle cx="{cx}" cy="{cy}" r="{r}" fill="{element.color.toHex()}" transform="rotate({rotation} {cx} {cy})" />""" &
      "\n"
  elif element of EllipseElement:
    let element = EllipseElement(element)
    var
      cx = element.x * width
      cy = element.y * height
      rx = element.radiusX * width
      ry = element.radiusY * height
    if element.centered:
      cx += width / 2
      cy += height / 2
    result =
      fmt"""<ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="{element.color.toHex()}" transform="rotate({rotation} {cx} {cy})" />""" &
      "\n"
  elif element of DiamondElement:
    let element = DiamondElement(element)
    let
      x1 = x + w / 2
      y1 = y
      x2 = x + w
      y2 = y + h / 2
      x3 = x + w / 2
      y3 = y + h
      x4 = x
      y4 = y + h / 2
    result = fmt"""<polygon points="{x1},{y1} {x2},{y2} {x3},{y3} {x4},{y4}" fill="{element.color.toHex()}" transform="rotate({rotation} {cx} {cy})" />""" & "\n"
  elif element of TextElement:
    let element = TextElement(element)
    let
      x = element.x * width
      y = element.y * height
      fontSize = element.fontSize * min(width, height)
    result = fmt"""<text x="{x}" y="{y}" font-size="{fontSize}" fill="{element.color.toHex()}" transform="rotate({rotation} {cx} {cy})">{element.text}</text>""" & "\n"
  else:
    result = ""

proc renderToSvg*(flag: Flag, width: int): string =
  let
    aspectRatio = flag.proportion.horizontal.float / flag.proportion.vertical.float
    height = int(width.float / aspectRatio)

  result = fmt"""<svg width="{width}" height="{height}">""" & "\n"

  for element in flag.elements:
    result &= renderElement(element, width.float, height.float)

  result &= "</svg>"
