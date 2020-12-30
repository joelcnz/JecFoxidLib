//#maybe change to just 'char'
//#draw letter
/// Letter
module jecfoxid.letter;

import std.stdio, std.string;
import jecfoxid;

version = new0;

/**
 * The letters that make up the text
 * 
 * May have the text bounce up and down
 */
struct Lettera {
private:
	static int m_idCurrent = 0;
	static JRectangle m_selectedGfx;
	int m_id;

	float m_xpos, m_ypos,
		m_xdir, m_ydir, m_width, m_height, m_roof, m_floor, m_xoff, m_yoff,
		abcol;
	char m_letter; //#maybe change to just 'char'
	SDL_Color m_colour, acol, bcol,
		m_altColour;
	bool m_alternate;
	ubyte m_shade;
	bool m_lock;
	bool m_selected;
	
	LetterManager m_letterManager;
	ubyte m_gfxIndex;
public:
	/// character set getter
	auto gfxIndex() { return m_gfxIndex; }

	/// character set setter
	void gfxIndex(ubyte gfx) {
		if (gfx < m_letterManager.bmpLettersMultiLength)
			m_gfxIndex = gfx;
		else
			assert(0, "index out of range!");
	}

	/// x position
	ref auto xpos() { return m_xpos; }

	/// y position
	ref auto ypos() { return m_ypos; }

	/// letter
	ref auto letter() { return m_letter; }

	/// lock state
	ref auto lock() { return m_lock; }

	/// alterating colour on/off switch
	ref auto alternate() { return m_alternate; }

	/// second colour for the alterating colour being on
	ref auto altColour() { return m_altColour; }

	/// Letter manager ?
	ref auto letterManager() { return m_letterManager; }

	/// Selected text setter
	void selected(bool selected) { m_selected = selected; }

	/// Selected text getter
	auto selected() { return m_selected; }
	
	void setPosition( float x, float y ) {
		xpos = x;
		ypos = y;
	}
	
	/// ctor new letter
	this(LetterManager letterManager0, char letter, ubyte gfxIndex = 0) {
		m_letterManager = letterManager0;
		m_gfxIndex = gfxIndex;
		m_id = m_idCurrent;
		++m_idCurrent;
		m_colour = SDL_Color(255, 180, 0, 255);
		alternate = false;
		this.letter = letter;
		m_xdir = 0;
		m_ydir = -1;
		m_roof = -999;
		m_floor = 0;
		m_height = 3;
		m_xoff = m_yoff = 0;
		m_shade = 0;
		acol = SDL_Color(255,0,0, 255);
		bcol = SDL_Color(0,0,255, 255);
		abcol = 0.0;

		m_selectedGfx = JRectangle(SDL_Rect(0,0, letterManager.charW, letterManager.charH),
			BoxStyle.solid,	SDL_Color(64,64,255,128));
	}
	
	/// dtor for any Allegro C created stuff
	~this() {
		//mixin(tce("/* ~this */ m_letter"));
	}
	
	/**
	 * For the letter behaviour(sp)
	 * 
	 * May:
	 * 
	 * 1. Bounce the letter up and down
	 * 
	 * 2. Keep changing the colour of the letter
	 */
	void update() {
		if ( m_roof == -999 ) {
			m_roof = -3, m_floor = 0;
		} else {
			m_yoff += m_ydir;
			immutable tmp = m_ydir;
			if ( m_yoff < m_roof )
				m_ydir = 1;

			if ( m_yoff > m_floor )
				m_ydir = -1;

			if ( tmp != m_ydir )
				 m_yoff -= m_ydir;
		}
		m_yoff = 0; //#to stop bouncing
		m_shade += 5;
		
		abcol += 256 / 100 * 3;
		if ( abcol > 100.0 )
			abcol = 0.0;
	}
	
	//#draw letter
	/**
	 * Draw the letter
	 * 
	 * Draws:
	 * 
	 * 1. Alternating
	 * 
	 * 2. Changing colour
	 */
	void draw(Display graph) @safe {
		if ((letter & 0xFF) >= 32
		  && xpos + letterManager.charW >= 0
		  && xpos <= letterManager.stampArea.width - letterManager.charW
		  && ypos + letterManager.charH >= 0
		  && ypos <= letterManager.stampArea.height + letterManager.charH) {
			if ( ! alternate ) {
				m_letterManager.chooseTextGfx(gfxIndex);
				SDL_Rect rpos = {cast(int)xpos, cast(int)ypos, letterManager.stampArea.width, letterManager.stampArea.height};

				if (m_selected) {
					graph.drawRect(Vec(xpos,ypos),Vec(xpos+letterManager.charW,ypos+letterManager.charH),Color(0,0,255,128), /* fill */ true);
				}

				graph.draw(letterManager.getTextureLetter(letter), Vec(xpos,ypos));
			 }
			else {
			}
		} // if letter
	}
}
