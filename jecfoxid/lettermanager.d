//#seems to be redundant
//#DISPLAY_W )
//#no draw here yet
//#Ctrl + Delete to suck
//#poll key event
//#read key input

//wait = /+ might possibly be true on wednesdays - Hamish +/ true;
//#remed out
//#page up
//#I do not know how!
//#setTextClipboard
//#draw
//#need more than that (eg g_cr as well)
//#unused
//#character adder
//#not sure about this/these
//#I don't know if 'ref' does anything.
//#is this worth keeping?
//#not nice
/// Letter Manager
///
/// Handles printing and layout of letters also input
module jecfoxid.lettermanager;

import std.stdio;
import std.range;
import std.conv;

import jecfoxid;

version = AutoScroll;

/// Letter Manager
final class LetterManager {
private:
	Image[char] m_bmpLetters;
	Image[char][] m_bmpLettersMulti;
	Image _stampArea;

	Vec _stampPos;
	int m_charW, /// char width
		m_charH; /// char height

	int m_pos;
	bool m_wait;
	Lettera[] m_letters;
	bool m_alternate;
	string m_copiedText;
	SDL_Color m_backgroundColour;

	JRectangle _cursorGfx;
	bool _textSelected;
	ubyte _currentgGfxIndex;
public:
	/// Text type
	enum TextType {block, line}
	TextType m_textType; /// Method text type

	auto getTextureLetter(char l) {
		assert(l in m_bmpLetters, "Character not found.");
		return m_bmpLetters[l];
	}

	ref auto stampPos() { return _stampPos; }
	auto stampArea() { return _stampArea; }

	ubyte currentGfxIndex() { return _currentgGfxIndex; }

	/// character set setter
	void currentGfxIndex(ubyte gfx) {
		if (gfx < bmpLettersMultiLength)
			_currentgGfxIndex = gfx;
		else
			assert(0, "index out of range!");
	}

	/// get/set letters (Letter[])
	ref auto letters() { return  m_letters; }
	//@property ref auto area() { return m_area; } /// get/set bounds
	
	/// get/set alternating colours on or off
	ref auto alternate() { return m_alternate; }
	
	/// get number of letters (including white space)
	auto count() { return cast(int)letters.length; } 
	
	/// access cursor position
	ref auto pos() { return m_pos; }
	
	/// access cursor position
	ref auto wait() { return m_wait; }
	//@property ref auto copiedText() { return m_copiedText; } /// access copiedText (string) //#remed out
	
	/// letters width
	ref auto charW() { return m_charW; }
	
	/// letters height
	ref auto charH() { return m_charH; }
	
	/// image letters
	ref auto bmpLetters() { return m_bmpLetters; }
	
	/// Copied text setter
	//void copiedText(string ctext0) { m_copiedText = ctext0; }
	void copiedText(string ctext0) {
		setClipboardText(ctext0);

		//m_copiedText = ctext0;
	}
	
	/// Copied text getter
	//string copiedText() { return m_copiedText; }
	string copiedText() { return getClipboardText; }

	/// copy selected text
	void copySelectedText() {
		import std.algorithm: each;

		m_copiedText.length = 0;
		foreach(l; letters)
			if (l.selected)
				m_copiedText ~= l.letter;
		copiedText(m_copiedText);
	}

	/// Paste copied text
	void pasteFromCopiedText() {
		pasteInputText;
	}

	ubyte bmpLettersMultiLength() {
		return cast(ubyte)m_bmpLettersMulti.length;
	}

	void chooseTextGfx(in ubyte index) @safe {
		if (index < m_bmpLettersMulti.length) {
			m_bmpLetters = m_bmpLettersMulti[index];
		} else
			throw new Exception(text(__FUNCTION__, " - index out of bounds (",
				index, ") limit is 0-", m_bmpLettersMulti.length - 1, ", defaulting to 0"));
	}
	
	/// ctor, setting area
	this(in string fileName, int charW0, int charH0, Vec loc, int swidth, int sheight) {
		this([fileName], charW0, charH0, loc, swidth, sheight);
	}
 
	// main ctor
	this(in string[] fileNames, int charW0, int charH0, in Vec loc, int swidth, int sheight) {
		charW = charW0;
		charH = charH0;
		stampPos = loc;
		foreach(name; fileNames) {
			m_bmpLettersMulti ~= getLetters(name);
		}

		_stampArea = new Image();
		_stampArea.createTexture(swidth,sheight,Color(0,0,0,255),PixelFormat.RGBA); // or PixelFormat.RGB

		_cursorGfx = JRectangle(SDL_Rect(0,0, charW, charH), BoxStyle.solid, SDL_Color(255,255,255, 64));

		debug(10)
			writeln(width, ' ', height);
		try
			chooseTextGfx(0); // 0 or 1
		catch(Exception e) {
			writeln(e.msg);
			chooseTextGfx(1);
		}
		pos = -1;
		g_doLetUpdate = true;
	}

	/// dtor Deal with C allocated memory
	~this() {
		import std.stdio : writeln;
		static cnt = 0;
		cnt += 1;
		writeln("Deallowcate! ", cnt);
		size_t total;
		foreach(bmps; m_bmpLettersMulti)
			foreach(bmp; bmps) {
				bmp.free();
				total += 1;
			}
		mixin(tce("total"));
		_stampArea.free();
	}

	/// copy letters to bmps
	auto getLetters(in string spritesFileName, string charSet = "") {
		if (charSet == "")
			foreach(l; ' ' .. '~' + 1)
				charSet ~= l;
		import std.file : exists;
		assert(exists(spritesFileName), spritesFileName~" not found");
		Image[char] ichars;
		import std.string : toStringz;
		Image[] icharsArr = loader.load!ImageSurface(spritesFileName).imageHandle.strip(Vec(0,0),charW,charH)[0 .. $-1];
		int ic;
		import std.algorithm : each;
		icharsArr.each!((e) {
			e.fromTexture();
			ichars[charSet[ic]] = e;
			ic += 1;
		});

		return ichars;
	}

	/// set type of text (block, line)
	void setTextType( TextType textType ) {
		m_textType = textType;
	}

	/// Get letter using passed index number
	//#is this worth keeping?
	Lettera opIndex(int pos) {
		assert( pos >= 0 && pos < count, "opIndex" );
		return letters[pos];
	}
	
	/// lock/unlock all letters
	void setLockAll( bool lock0 ) {
		foreach( l; letters )
			l.lock = lock0;
	}
	
	/// Add text with new line added to the end
	auto addTextln(T...)(T args) {
		import std.typecons: tuple;
		import std.conv: text;

		immutable str = text(tuple(args).expand);
		string result = getText() ~ str ~ "\n";
		setText( result );

		return result;
	}
	
	/// Add text without new line being added to the end
	void addText(T...)(T args) {
		import std.typecons: tuple;
		import std.conv: text;

		auto str = text(tuple(args).expand);
		auto lettersStartLength = count;
		letters.length = lettersStartLength + str.length;
		foreach( index, l; str )
			letters[lettersStartLength + index] = Lettera(this,l, currentGfxIndex);
		pos = count - 1.to!int();
		placeLetters();
	}

	/// apply text from string - also places text
	void setText(T...)(T args) {
		import std.typecons: tuple;
		import std.conv: text;

		auto str = text(tuple(args).expand);
		letters.length = str.length;
		foreach(index, l; str)
			letters[index] = Lettera(this,l, currentGfxIndex);
		pos = cast(int)letters.length - 1;
		placeLetters();
	}

	/// Get converted text (string format)
	string getText() {
		auto str = new char[](letters.length);
		foreach(index, ref l; letters) { // ref for more speed
			str[index] = cast(char)l.letter;
		}

		return str.idup;
	}
	
	/// Postion text for display
	void placeLetters() {
		SDL_Color[] altcols = [SDL_Color(255, 180, 0, 0xFF), SDL_Color(255,0,0, 0xFF)];
		auto altcolcyc = 0;
		int x = 0, y = 0;
		int i = 0;
		Lettera l;
		while(i < letters.length) { // foreach(i, ref l; letters ) {
			l = letters[i];
			auto let = cast(char)l.letter;
			// if do new line
			if ( x + charW > _stampArea.width || let == '\n') {
				if (let == '\n') {
					x = -charW;
				} else {
					immutable iwas = i;

					int xi = x;
					x = 0;
					import std.algorithm : canFind;

					//while(! " -,.:;".canFind(letters[i].letter)) {
					while(! " ".canFind(letters[i].letter)) {
						i -= 1;
						xi -= charW;
						if (i == -1 || xi < 0) {
							i = iwas;
							l = letters[i];
							break;
						} else l = letters[i];
					}
					if (i != iwas)
						x = -charW;
					else {
						if (letters[i].letter == ' ') {
							i += 1;
							if (i != letters.length)
								l = letters[i];
						}
					}
				}
				y += charH;
				if ( alternate == true ) {
					altcolcyc |= 1; // or should it be altcolcyc ^= 1; //( altcolcyc == 0 ? 1 : 0 );
				}
				// scroll
				if ( y + charH > stampArea.height) {
					foreach(ref l2; letters )
						l2.ypos -= charH;
					y -= charH;
				}
			}
			l.setPosition( x, y );
			//mixin(tce("x y".split));
			if ( alternate == true ) {
				l.alternate = true; //#not nice
				l.altColour = altcols[ altcolcyc ];
			}
			if (i < letters.length)
				letters[i] = l;
			x += charW;
			i += 1;
		} // while
	}
	
	/// Eg. bouncing letters
	void update() {
		foreach( ref l; letters ) //#I don't think 'ref' does anything.
			l.update();
	}
	
	// array, start pos, step, delegate
	//int search( Letter[] arr, int stpos, int step, bool delegate ( Letter ) let ) {
	/// Check each letter starting from a curtain postion, going a curtain direction and not past a curtain limit
	int searchForProperty( int stpos, int step, int limit, bool delegate ( int ) dg ) {
		foreach( i; iota( stpos, limit, step ) )
			if ( dg( i ) == true )
				return i;
		return -1;
	}

	/// Lock letter
	bool pLock( int a ) {
		return letters[ a ].lock;
	}

	/// Copy input text
	void copyInputText() {
		if (count > 1) {
			int lastLocked = searchForProperty( count() - 1, -1, -1, 
				&pLock //#not sure about this/these
			);
			
			if (lastLocked != count) {
				copiedText = getText()[ lastLocked + 1.. $ ];
				//#setTextClipboard
				//setTextClipboard( copy );
			}
		}
	}
	
	/// Paste input text
	void pasteInputText() {
		letters.length = searchForProperty(
			/+ start: +/ count - 1,
			/+ end: +/ -1,
			/+ step: +/ -1,
			/+ rule(s): +/ &pLock
		) + 1;
		addText( copiedText );
		pos = count - 1;
	}

	/// Main function for recieving key presses
	char doInput(ref bool enterPressed) {
		char c;
		auto st = jx.getKeyDString;
		g_doLetUpdate = false;
		if (! jx.keyControl && ! jx.keyAlt && ! jx.keySystem && st.length == 1) {
			c = cast(char)st[0];
			g_doLetUpdate = true;
		}

		void ifUnselect() {
			if (! jx.keyShift && _textSelected) {
				import std.algorithm: each;

				letters.each!((ref l) => l.selected = false);
				_textSelected = false;
			}
		}

		void directionalMostly() {
			if (jx.keyControl) {
				if (g_keys[SDL_SCANCODE_A].keyTrigger) {
					import std.algorithm: each;

					letters.each!((ref l) => l.selected = ! l.lock ? true : false);
					g_doLetUpdate = true;
					foreach(ref l; letters) { 
						if (! l.lock) {
							_textSelected = true;
							break;
						}
					}
				}

				if (gGlobalText && g_keys[SDL_SCANCODE_C].keyTrigger) {
					//copyInputText();
					copySelectedText;
					g_doLetUpdate = true;
				}

				if (gGlobalText && g_keys[SDL_SCANCODE_V].keyTrigger) {
					//pasteInputText();
					pasteFromCopiedText;
					g_doLetUpdate = true;
				}

				if (g_keys[SDL_SCANCODE_UP].keyInput) {
					int i = pos;
					for( i = pos; i > -1 && letters[ i ].lock == false; --i )
					{}
					pos = i;
					g_doLetUpdate = true;
					ifUnselect;
				}

				if (g_keys[SDL_SCANCODE_DOWN].keyInput) {
					pos = count - 1;
					g_doLetUpdate = true;
					ifUnselect;
				}

				if (g_keys[SDL_SCANCODE_LEFT].keyInput && pos >= 0 ) {
					int i = pos;
					for( ; i > 0 && letters[ i ].lock == false
						&& cast(int)letters[ i ].xpos != 0; --i ) { }
					pos = i - 1;
					g_doLetUpdate = true;
					ifUnselect;
				}
				
				if (g_keys[SDL_SCANCODE_RIGHT].keyInput && pos < count - 1 ) {
					ifUnselect;
					int hght = cast(int)letters[ pos > -1 ? pos + 1 : 1 ].ypos;
					auto offTheEnd = true;
					foreach( i; iota( pos, count, 1 ) ) {
						if (i < 0) {
							writeln("Out of range: ", i);
							break;
						}
						if ( letters[ i ].ypos != hght ) {
							if ( letters[ i ].xpos + charW * 2 > stampArea.width )
								i -= 2;
							else
								--i;
							pos = i;
							offTheEnd = false;
							break;
						}
					}
					if ( offTheEnd == true )
						pos = count - 1;
					g_doLetUpdate = true;
					ifUnselect;
				}
			} // system key
				
			if (jx.keyAlt) {
				if (g_keys[SDL_SCANCODE_LEFT].keyInput) {
					if ( pos > -1 && letters[ pos ].lock != true ) {
						int i = 0;
						for( i = pos - 1;
							i > -1 && letters[ i ].letter != ' '
							&& letters[ i ].lock == false; --i )
						{}
						if ( pos > -1 )
							pos = i;
					}
					g_doLetUpdate = true;
					ifUnselect;
				}
				if (g_keys[SDL_SCANCODE_RIGHT].keyInput) {
					int i = 0;
					for( i = pos + 1;
						i < letters.length &&
						letters[ i ].letter != ' ' ; ++i )
					{}
					if ( i < letters.length )
						pos = i;
					else
						pos = letters.length.to!int() - 1.to!int();
					g_doLetUpdate = true;
					ifUnselect;
				}
			} // alt key
				
			if (! jx.keyControl && ! jx.keyAlt && ! jx.keySystem) {
				if (g_keys[SDL_SCANCODE_LEFT].keyInput && count > 0 ) {
					if ( pos - 1 > -2 )
						--pos;
					if ( letters[ pos + 1 ].lock == true )
						++pos;
					g_doLetUpdate = true;
					ifUnselect;
				}

				if (g_keys[SDL_SCANCODE_RIGHT].keyInput) {
					++pos;
					if ( pos >= letters.length  )
						--pos;
					g_doLetUpdate = true;
					ifUnselect;
				}
				
				if (g_keys[SDL_SCANCODE_UP].keyInput && count > 0 && pos != -1 ) {
					int xpos = cast(int)letters[ pos ].xpos,
						ypos = cast(int)letters[ pos ].ypos - charH;
					foreach_reverse(i, l; letters[0 .. pos]) {
						if (l.lock == true)
							break;
						if (cast(int)l.xpos == xpos && cast(int)l.ypos == ypos) {
							pos = cast(int)i;
							break;
						}
					}
					g_doLetUpdate = true;
					ifUnselect;
				} // key up
				
				if (g_keys[SDL_SCANCODE_DOWN].keyInput && count > 0 && pos != -1 ) {
					int xpos = cast(int)letters[ pos ].xpos,
						ypos = cast(int)letters[ pos ].ypos + charH;
					foreach(i, l; letters[pos .. $]) {
						if (cast(int)l.xpos == xpos && cast(int)l.ypos == ypos) {
							pos = pos + cast(int)i;
							break;
						}
					}
					g_doLetUpdate = true;
					ifUnselect;
				} // key down
			} // if not control pressed
			
		}
		directionalMostly();
		auto doPut = false;
		
		//#character adder
		if ( chr( c ) >= 32 && c != char.init) {
			doPut = true;
			//insert letter
			// pos = -1
			// Bd press a -> aBc
			// #              #
			//mixin( traceLine( "pos letters.length".split ) );
			letters = letters[ 0 .. pos + 1 ] ~
				Lettera(this,chr(c), currentGfxIndex) ~ letters[pos + 1 .. $];
			++pos;
			placeLetters();
			g_doLetUpdate = true;
		}
		
		if (g_keys[SDL_SCANCODE_RETURN].keyInput) {
			enterPressed = true;
			final switch ( m_textType ) {
				case TextType.block:
					letters = letters[ 0 .. pos + 1 ]
						~ Lettera(this, '\n', currentGfxIndex)
						~ letters[ pos + 1 .. $ ];
					pos += 1;
					placeLetters();
				break;
				case TextType.line:
					letters ~= Lettera(this, '\n', currentGfxIndex);
				break;
			} // switch
			g_doLetUpdate = true;
		}
		
		if (! jx.keyControl && g_keys[SDL_SCANCODE_BACKSPACE].keyInput && pos > -1
			&& letters[ pos ].lock == false) {
			if (_textSelected) {
				int i;
				for( i = count() - 1;
					i >= 0 && letters[ i ].lock == false; --i )
				{}
				if (i < 0) {
				} else {
					int st2 = -1, ed = -1;
					foreach(i2, l; letters[i .. $]) {
						if (l.selected && st2 == -1) {
							st2 = cast(int)i2 + i;
						} else if (st2 != -1 && ! l.selected) {
							ed = cast(int)i2 + i - 2;
						}
					}
					if (ed == -1)
						ed = count;
					trace!st2; trace!ed;
					if (st2 == -1) {
						gh("Some thing wrong!");
					} else {
						letters = letters[0 .. st2] ~
							letters[ed .. $];
						pos = i;
						placeLetters();
						g_doLetUpdate = true;
					}
					_textSelected = false;
				}
			} else {
				doPut = true;
				version( Terminal )
					write( " \b" );
				letters = letters[ 0 .. pos ] ~ letters[ pos + 1 .. $ ];
				--pos;
				placeLetters();
				g_doLetUpdate = true;
			}
		}
		
		//Suck - it sucks (letters that is)
		version(none) { //#Ctrl + Delete to suck
		if (g_keys[Keyboard.Key.BackSpace].keyInput
			&& pos != count - 1) {
			// pos = 0
			// aBc press del -> aC
			//  #                #
			letters = letters[ 0 .. pos + 1 ] ~ letters[ pos + 2 .. $ ],
			placeLetters();
		}
		} // version

		version( Terminal ) {
			if ( doPut ) 
				write( cast(char)c ~ "#\b" );
			std.stdio.stdout.flush;
		}

		return chr( c ); //#unused
	}
	
	/// Text and cursor
	void draw(Display graph) {
		if (g_doLetUpdate) {
			g_doLetUpdate = false;

			float xpos, ypos;
			if (letters.length > 0 && pos > -1) {
				xpos = letters[pos].xpos;
				ypos = letters[pos].ypos;
			} else {
				xpos = charW;
				ypos = 0;
			}
			if (xpos + charW + charW >= stampArea.width) {
				xpos = -charW;
				ypos += charH;
			}
			xpos += charW;

			_cursorGfx.pos = Vec(cast(float)xpos + charW, cast(float)ypos);

			stampArea.edit((Display graph) @safe {
				graph.drawRect(Vec(0,0), Vec(stampArea.width,stampArea.height),Color(0,0,0,255), /*fill*/ true);
				graph.drawRect(Vec(xpos,ypos), Vec(xpos+charW,ypos+charH),Color(0,0,255,128), /*fill*/ true);
			});

			if (count > 0) {
				stampArea.edit((Display graph) @trusted {
					foreach(ref l; letters)
						l.draw(graph);
				});
			}
		} // if update
		gGraph.draw(_stampArea,stampPos);
	}
}
