include stdio

import structs/ArrayList
import FileReader, FileWriter, Reader, BufferWriter, BufferReader
import native/[FileWin32, FileUnix]

/**
 * Represents a file/directory path, allows to retrieve informations like
 * last date of creation/access/modification, permissions, size,
 * existence, content, type, children...
 *
 * You can also create directories, remove files, read their content,
 * copy them, write to them.
 *
 * For input/output (I/O) beyond 'reading to a String' and
 * 'writing a String', see the FileReader and FileWriter classes
 */
File: abstract class {
	path: String { get set }
	name ::= this getName()
	parent ::= this getParent()
	extension ::= this getExtension()
	nameWithoutExtension ::= this getNameWithoutExtension()
	pathWithoutExtension ::= this getPathWithoutExtension()
	children: VectorList<This> { get {
		this getChildren()
	}}

	rectifySeparator: func {
		if (this dir() && !this path endsWith(This separator)) {
			oldPath := this path
			this path = oldPath + This separator
			oldPath free()
		}
		else if (!this dir() && this path endsWith(This separator)) {
			newPath := this path trimRight(This separator)
			this path free()
			this path = newPath
		}
	}
	// true if it's a directory
	dir: abstract func -> Bool
	// true if it's a file (ie. not a directory nor a symbolic link)
	file: abstract func -> Bool
	// true if the file is a symbolic link
	link: abstract func -> Bool
	// the size of the file, in bytes
	getSize: abstract func -> LLong
	// true if the file exists
	exists: abstract func -> Bool
	// the permissions for the owner of this file
	ownerPerm: abstract func -> Int
	// the permissions for the group of this file
	groupPerm: abstract func -> Int
	// the permissions for the others
	otherPerm: abstract func -> Int
	// true if a file is executable by the current owner
	executable: abstract func -> Bool

	setExecutable: abstract func (exec: Bool) -> Bool
	getPath: func -> String { this path }
	getName: func -> String {
		trimmed := this path trim(This separator)
		idx := trimmed lastIndexOf(This separator)
		idx == -1 ? trimmed : trimmed substring(idx + 1)
	}
	getParent: func -> This {
		pName := parentName()
		if (pName) return new(pName)
		if (path != "." && !path startsWith(This separator))
			return new(".") // return the current directory
		return null
	}
	getExtension: func -> String {
		result := ""
		if (!this dir()) {
			index := this path lastIndexOf('.')
			if (index > 0)
				result = this path substring(index + 1)
		}
		result
	}
	getNameWithoutExtension: func -> String {
		result := this name
		if (this hasExtension()) {
			result = this name substring(0, this name lastIndexOf('.'))
		}
		result
	}
	getPathWithoutExtension: func -> String {
		result := this path
		if (this hasExtension()) {
			result = this path substring(0, this path lastIndexOf('.'))
		}
		result
	}
	hasExtension: func -> Bool {
		(this path lastIndexOf('.') > 0) && (!this dir())
	}
	parentName: func -> String {
		idx := path lastIndexOf(This separator)
		if (idx == -1) return null
		return path substring(0, idx)
	}
	// Create a named pipe at the path specified by this file
	mkfifo: func -> Int { this mkfifo(0c755) }
	mkfifo: abstract func ~withMode (mode: Int32) -> Int
	// Create a directory at the path specified by this file,
	mkdir: func -> Int { this mkdir(0c755) }
	mkdir: abstract func ~withMode (mode: Int32) -> Int
	// Create a directory at the path specified by this file and all the parent directories if needed
	mkdirs: func { this mkdirs(0c755) }
	mkdirs: func ~withMode (mode: Int32) -> Int {
		p := this parent
		if (p) {
			p mkdirs(mode)
			p free()
		}
		mkdir()
	}

	lastAccessed: abstract func -> Long
	lastModified: abstract func -> Long
	created: abstract func -> Long
	relative: abstract func -> Bool
	getAbsolutePath: abstract func -> String
	getLongPath: func -> String { path }
	getAbsoluteFile: func -> This { new(getAbsolutePath()) }
	getReducedPath: func -> String {
		elems := ArrayList<String> new()
		tokens := this path split(This separator)
		for (elem in tokens)
			if (elem == "..") {
				if (!elems empty())
					elems removeAt(elems lastIndex())
				else
					elems add(elem)
			} else if (elem != "." && elem != "")
				elems add(elem)
		result := elems join(This separator)
		if (path startsWith(This separator))
			result = This separator + result
		result
	}
	getReducedFile: func -> This { new(this getReducedPath()) }
	getChildrenNames: abstract func -> VectorList<String>
	getChildren: abstract func -> VectorList<This>
	rm: func -> Bool { _remove(this) }
	rm_rf: func -> Bool {
		if (dir())
			for (child in this getChildren())
				if (!child rm_rf())
					return false
		rm()
	}
	// Searches for a file with given name until cb returns false
	find: func (name: String, cb: Func (This) -> Bool) -> Bool {
		if (this getName() == name)
			if (!cb(this))
				return true // abort if caller is happy

		if (this dir()) {
			children := this getChildren()
			for (child in children)
				if (child find(name, cb))
					return true // abort if caller found happiness in a sub-directory
		}
		false
	}
	find: func ~first (name: String) -> This {
		result: This
		this find(name, |f|
			result = f
			false
		)
		result
	}
	findShallow: func (name: String, level: Int, cb: Func (This) -> Bool) -> Bool {
		fName := getName()
		if (fName == name)
			if (!cb(this))
				return true // abort if caller is happy

		if (dir() && level >= 0) {
			if (fName == ".git")
				return false // skip

			children := this getChildren()
			for (child in children)
				if (child findShallow(name, level - 1, cb))
					return true // abort if caller found happiness in a sub-directory
		}

		false
	}
	findShallow: func ~first (name: String, level: Int) -> This {
		result: This
		this findShallow(name, level, |f|
			result = f
			false
		)
		result
	}
	copyTo: func (dstFile: This) {
		dstParent := dstFile parent
		dstParent mkdirs()
		dstParent free()
		src := FileReader new(this)
		dst := FileWriter new(dstFile)
		max := 8192
		buffer := Char[max] new()

		while (src hasNext?()) {
			num := src read(buffer data, 0, max)
			dst write(buffer data, num)
		}

		buffer free()
		dst close()
		src close()
		dst free()
		src free()
	}
	read: func -> String {
		fR := FileReader new(this)
		bW := BufferWriter new() .write(fR) .close()
		fR close()
		bW buffer toString()
	}
	write: func ~string (str: String) {
		FileWriter new(this) write(BufferReader new(str _buffer)) .close()
	}
	write: func ~reader (reader: Reader) {
		FileWriter new(this) write(reader) . close()
	}
	// Walk this directory and call `f` on all files it contains, recursively, until f returns false
	walk: func (f: Func(This) -> Bool) -> Bool {
		result := true
		if (this file()) {
			if (!f(this))
				result = false
		} else if (this dir())
			for (child in this getChildren())
				if (!child walk(f))
					result = false
		result
	}
	/**
	 * If this file has path: some/base/directory/sub/path
	 * And base is a file like: some/base/directory
	 * This method will return a File with path "sub/path"
	 */
	rebase: func (base: This) -> This {
		left := base getReducedFile() getAbsolutePath() replaceAll(This separator, '/')
		full := getReducedFile() getAbsolutePath() replaceAll(This separator, '/')

		if (!left endsWith("/")) {
			left = left + "/"
		}
		right := full substring(left size)
		This new(right)
	}
	getChild: func (childPath: String) -> This { This new(this path, childPath) }
	getChild: func ~file (file: This) -> This { this getChild(file path) }
	toString: func -> String { "File(#{path})" }

	separator: static Char
	pathDelimiter: static Char
	MAX_PATH_LENGTH := static 16383

	new: static func (.path) -> This {
		version (unix || apple) {
			return FileUnix new(path)
		}
		version (windows) {
			return FileWin32 new(path)
		}
		Exception new(This, "Unsupported platform!\n") throw()
		null
	}
	new: static func ~assemble (args: ...) -> This {
		This new(This join(args))
	}
	getCwd: static func -> String {
		ooc_get_cwd()
	}
	join: static func (args: ...) -> String {
		first := true
		result := CharBuffer new()
		args each(|arg|
			path := match arg {
				case f: This =>
					f path
				case s: String =>
					s
			}
			if (first)
				first = false
			else
				result append(separator)
			result append(path)
		)
		result toString()
	}
}

_isDirHardlink: func (dir: CString) -> Bool {
	(dir[0] == '.') && (dir[1] == '\0' || ( dir[1] == '.' && dir[2] == '\0'))
}
