import io/[Reader, File]

FileReader: class extends Reader {
	fileName: Text
	file: FStream

	init: func ~withFile (fileObject: File) {
		init(Text new(fileObject getPath()))
	}
	init: func ~withName (fileName: Text) {
		// mingw fseek/ftell are *really* unreliable with text mode
		// if for some reason you need to open in text mode, use
		// FileReader new(fileName, "rt")
		init(fileName, t"rb")
	}

	/**
	 * Open a file for reading, given its name and the mode in which to open it.
	 *
	 * "r" = for reading
	 * "w" = for writing
	 * "r+" = for reading and writing
	 *
	 * suffix "a" = appending
	 * suffix "b" = binary mode
	 * suffix "t" = text mode (warning: rewind/mark are unreliable in text mode under mingw32)
	 */
	init: func ~withMode (=fileName, mode: Text) {
		(fileNameString, modeString) := (this fileName take() toString(), mode toString())
		file = FStream open(fileNameString, modeString)
		fileNameString free()
		modeString free()
		if (!file) {
			err := getOSError()
			Exception new(This, "Couldn't open #{fileName} for reading: #{err}") throw()
		}
	}

	init: func ~fromFStream (=file)
	free: override func {
		this fileName free(Owner Receiver)
		super()
	}
	read: override func (buffer: Char*, offset: Int, count: SizeT) -> SizeT {
		this file read(buffer + offset, count)
	}
	read: func ~fullBuffer (buffer: CharBuffer) {
		count := file read(buffer data, buffer capacity)
		buffer size = count
	}
	read: override func ~char -> Char {
		this file readChar()
	}
	hasNext?: override func -> Bool {
		feof(file) == 0
	}
	seek: override func (offset: Long, mode: SeekMode) -> Bool {
		file seek(offset, match mode {
			case SeekMode SET => SEEK_SET
			case SeekMode CUR => SEEK_CUR
			case SeekMode END => SEEK_END
			case =>
				Exception new("Invalid seek mode: %d" format(mode)) throw()
				SEEK_SET
		}) == 0
	}
	mark: override func -> Long {
		this marker = file tell()
		this marker
	}
	close: override func {
		this file close()
	}
}
