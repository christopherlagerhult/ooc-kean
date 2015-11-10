use ooc-base
use ooc-unit
use ooc-math
import math

TextTest: class extends Fixture {
	init: func {
		super("Text")
		this add("constructors", func {
			text := Text new(c"test string", 5)
			expect(text give() toString() == "test ")
			text = Text new("string")
			text2 := Text new("str")
			expect(text count == 6)
			expect(text toString() == "string")
			expect(text isEmpty == false)
			text = text give()
			text free()
			expect(text count == 0)
			expect(text isEmpty)
			expect(Text new(c"from const") == "from const")
			expect(Text new(c"12345") count == 5)
		})
		this add("ownership", func {
			text := Text new(c"vidhance", 8)
			text2 := text copy()
			expect(text free(), is false)
			expect(text count, is equal to(0))
			expect(text2 free())
			expect(text2 count, is equal to(0))
		})
		this add("is empty", func {
			text := Text new(c"a string", 8)
			expect(text isEmpty, is false)
			expect(text free(), is false)
			expect(text isEmpty)
		})
		this add("searching", func {
			text := Text new("test string")
			text2 := Text new("test")
			expect(text endsWith(text))
			expect(text beginsWith(text))
			expect(text endsWith(text2) == false)
			expect(text beginsWith(text2))
			expect(text2 beginsWith(text2))
			expect(text[0] == 't')
			expect(text[1] == 'e')
			expect(text find('t') == 0)
			expect(text find('e') == 1)
			expect(text find('t', 1) == 3)
			expect(text find('x') == -1)
			expect(text find(text) == 0)
			expect(text find(Text new("test")) == 0)
			expect(text find(Text new("est")) == 1)
			expect(text find("st") == 2)
			expect(text find(Text new("st"), 4) == 5)
			expect(text find("string") == 5)
			expect(text find(Text new("bad")) == -1)
		})
		this add("slicing", func {
			text := Text new(c"text to slice", 13)
			expect(text == text copy())
			expect(text == text slice(0, text count))
			expect(text slice(0, 4) == Text new(c"text", 4))
			expect(text slice(8, 5) == Text new(c"slice", 5))
			expect(text slice(40, 23) isEmpty)
			expect(text slice(-2, -2) == "li")
			expect(text[0 .. 2] == "tex")
			expect(text[0 .. 123] == text)
			expect(text[123 .. 998] isEmpty)
		})
		this add("splitting", func {
			text := Text new("0,1,2,3,4")
			parts := text split(',')
			expect(parts count == 5)
			expect(parts[0] == "0")
			expect(parts[1] == "1")
			expect(parts[2] == "2")
			expect(parts[3] == "3")
			expect(parts[4] == "4")
			text = Text new(";;;0;;1;;;2;;3;")
			parts = text split(";")
			expect(parts count == 12)
			expect(parts[0] == Text empty)
			expect(parts[3] == "0")
			expect(parts[5] == "1")
			expect(parts[8] == "2")
			expect(parts[10] == "3")
			text = Text new("</br>simple</br>text</br></br>to</br>split")
			parts = text split(Text new(c"</br>", 5))
			expect(parts count == 6)
			expect(parts[0] == Text empty)
			expect(parts[1] == "simple")
			expect(parts[2] == "text")
			expect(parts[3] == Text empty)
			expect(parts[4] == "to")
			expect(parts[5] == "split")
		})
		this add("Convert to Int", func {
			expect(Text new("1") toInt(), is equal to(1))
			expect(Text new("-1") toInt(), is equal to(-1))
			expect(Text new("-932") toInt(), is equal to(-932))
			expect(Text new("871") toInt(), is equal to(871))
			expect(Text new("bad") toInt(), is equal to(0))
			expect(Text new("123one") toInt(), is equal to(123))
			expect(Text new("101") toInt(), is equal to(101))
			for (i in 1 .. 100)
				for (j in 1 .. 100)
					expect(Text new((i * j) toString()) toInt(), is equal to(i * j))
		})
		this add("Convert to Int (base 16)", func {
			expect(Text new("bad") toInt~inBase(16), is equal to(11 * 16 * 16 + 10 * 16 + 13))
			expect(Text new("BEEF") toInt(), is equal to(0))
			expect(Text new("BEEF") toInt~inBase(16), is equal to(48879))
			expect(Text new("BEEF") toInt~inBase(16), is equal to(Text new("beef") toInt~inBase(16)))
			expect(Text new("0xff") toInt(), is equal to(255))
			expect(Text new("0x11") toInt(), is equal to(17))
			expect(Text new("0xAA") toInt(), is equal to(170))
			expect(Text new("0xffZZZ") toInt(), is equal to(255))
		})
		this add("Convert to Int (other bases)", func {
			expect(Text new("101") toInt~inBase(2), is equal to(5))
			expect(Text new("101") toInt~inBase(8), is equal to(8 * 8 + 1))
			expect(Text new("101") toInt~inBase(7), is equal to(7 * 7 + 1))
			expect(Text new("654") toInt~inBase(6), is equal to(0))
			expect(Text new("654") toInt~inBase(7), is equal to(4 + 5 * 7 + 6 * 7 * 7))
		})
		this add("Convert to Long and ULong", func {
			expect(Text new(INT_MAX toString()) toLong(), is equal to(INT_MAX))
			expect(Text new("0xDEADBEEF") toULong(), is equal to(3735928559))
			expect(Text new("-9") toULong(), is equal to(0))
			expect(Text new("-9") toLLong(), is equal to(-9))
			expect(Text new("-9") toLong(), is equal to(-9))
		})
		this add("Convert to Float", func {
			tolerance := 0.001f
			expect(Text new("1") toFloat(), is equal to(1.0f) within(tolerance))
			expect(Text new("-1.0") toFloat(), is equal to(-1.0f) within(tolerance))
			expect(Text new("-1.") toFloat(), is equal to(-1.0f) within(tolerance))
			expect(Text new("22.5") toFloat(), is equal to(22.5f) within(tolerance))
			expect(Text new("123.763") toFloat(), is equal to(123.763f) within(tolerance))
			for (i in 1 .. 100)
				for (j in 1 .. 100)
					expect(Text new((0.5f * i * j) toString()) toFloat(), is equal to(0.5f * i * j) within(tolerance))
		})
		this add("Convert to Float (scientific notation)", func {
			tolerance := 0.001f
			expect(Text new("1e0") toFloat(), is equal to(1.0f) within(tolerance))
			expect(Text new("5E-2") toFloat(), is equal to(0.05f) within(tolerance))
			expect(Text new("2E12") toLDouble(), is equal to(2.0 * pow(10, 12) as LDouble) within(tolerance as LDouble))
			expect(Text new("2E12") toDouble(), is equal to(2.0 * pow(10, 12) as Double) within(tolerance as Double))
			expect(Text new("6.5E5") toFloat(), is equal to(6.5f * pow(10, 5) as Float) within(tolerance))
			expect(Text new("-34.5E-2") toFloat(), is equal to(-0.345f) within(tolerance))
		})
		this add("MakeTextLiteral", func {
			text := makeTextLiteral(c"Hello", 5)
			text2 := t"Hello"
			expect(text == text2)
		})
		this add("copyTo", func {
			text := Text new("test string")
			buffer := TextBuffer new(11)
			text copyTo(buffer)
			text2 := Text new(buffer)
			expect(text == text2)
			text free()
			text2 free()
		})
		this add("trim", func {
			paddedText := t"  \t test \n test \r\n\t "
			trimmedText := paddedText trim()
			expect(trimmedText == t"test \n test")
			paddedText free()
			trimmedText free()
		})
	}
}

TextTest new() run()
