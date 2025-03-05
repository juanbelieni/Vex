import flag
import std/strutils
import std/strformat
import std/math

func toHex*(color: Color): string =
  result = "#" & toHex(color.r, 2) & toHex(color.g, 2) & toHex(color.b, 2)

proc renderElement*(element: Element, width, height: float): string =
  let
    x = element.x * width
    y = element.y * height
    w = element.width * width
    h = element.height * height
    rotation = element.rotation
    cx = x + w / 2
    cy = y + h / 2

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
      let stripeWidth = width / stripeCount
      for i, color in element.colors:
        let
          x = i.float * stripeWidth
          y = element.y * height
          w = stripeWidth
          h = height
        result &=
          fmt"""<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{color.toHex()}" />""" &
          "\n"
    else:
      let stripeHeight = height / stripeCount
      for i, color in element.colors:
        let
          x = element.x * width
          y = i.float * stripeHeight
          w = width
          h = stripeHeight
        result &=
          fmt"""<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="{color.toHex()}" />""" &
          "\n"
    result &= "</g>" & "\n"
  elif element of CircleElement:
    let element = CircleElement(element)
    let
      cx = element.x * width
      cy = element.y * height
      r = element.radius * min(width, height)
    result =
      fmt"""<circle cx="{cx}" cy="{cy}" r="{r}" fill="{element.color.toHex()}" transform="rotate({rotation} {cx} {cy})" />""" &
      "\n"
  elif element of EllipseElement:
    let element = EllipseElement(element)
    let
      cx = element.x * width
      cy = element.y * height
      rx = element.radiusX * width
      ry = element.radiusY * height
    result =
      fmt"""<ellipse cx="{cx}" cy="{cy}" rx="{rx}" ry="{ry}" fill="{element.color.toHex()}" transform="rotate({rotation} {cx} {cy})" />""" &
      "\n"
  else:
    result = ""

proc renderToSvg*(flag: Flag, width: int): string =
  let
    aspectRatio = flag.proportions.numerator.float / flag.proportions.denominator.float
    height = int(width.float / aspectRatio)

  result = fmt"""<svg width="{width}" height="{height}">""" & "\n"

  for element in flag.elements:
    result &= renderElement(element, width.float, height.float)

  result &= "</svg>"
