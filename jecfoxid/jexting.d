module jecfoxid.jexting;

//#like black
//#not being used
//#define
import std.stdio;
import core.thread;
import std.string;
import std.conv;
import std.datetime;
import std.range;
import std.file;

import jecfoxid;

//version = chunk;

struct JText {
	Vec position;
	string text;
	Font font;
	int fontSize;
	Color colour = Color(255,255,255);

	private string fontFileName;

	void setSize(in int fontSize0) {
		//fontFileName.gh;
		assert(exists(fontFileName), "File not exist");
		if (! font)
			font = new Font();
		else {

		}
		try
			font.load(fontFileName,fontSize0);
		catch(Exception e)
			writeln(e.msg);
		assert(font, "font not load");
	}
	float getWidth() { return getWidthText(text, font); }

	this(in string text, Font font) {
		this.text = text;
		this.font = font;
		this.fontSize = font.size;
		this.fontFileName = font.name;
		colour = Color(255,180,0);
	}

	this(in string text, in string fontFileName, in int fontSize) {
		this.text = text;
		this.fontSize = fontSize;
		this.fontFileName = fontFileName;
		setSize(fontSize);
		colour = Color(255,180,0);
	}

	void draw(Display graph) {
		graph.drawText(text,font,colour,position);
	}
}

/+
class Jexting {
private:
	Text[] _txts;
	int _fontSize;
	int _textHeight;
	Color _colour;
	Vec _pos,
			 _spd;
	enum Type {oneLine, history} //#define oneLine: just one line doesn't move. History: adds lines from input, and moves down
	Type _type;
	
	SDL_Rect _rect;

	bool _edge;
	//Text[] _txtsEdge; //#like black
public:
	@property {
		void type(Type type) { _type = type; }
		auto type() { return _type; }

		void edge(bool edge) { _edge = edge; }
		auto edge() { return _edge; }

		auto txts() { return _txts; }

		void colour(Color col) { _colour = col; }
	}
	
	this(in string fontFileName, int fontSize, Type type = Type.oneLine) {
		_fontSize = fontSize;
		_pos = Vec(300, 200);
		_spd = Vec(0,0);
		_edge = false;
		_type = type;
	}

/+
	void setEdge() {
		foreach(tx; _txts) {
			_txtsEdge ~= new Text(tx.txtStr, g_font, _fontSize);
			_txtsEdge[$ - 1].color = 0;
		}
	}
+/

/+
	void chunkCate(string str, int chunkSize) {
		_txts.length = 0;
			
		auto txts = wrap(str, chunkSize, null, null, 4).split('\n');
		debug(5)
			writeln([txts]);
		import std.array;
		if (txts.length && txts[$ - 1] == "")
			txts.popBack;
		
		debug(5)
			writeln([txts]);
		foreach(i, txt; txts) {
			_txts ~= Text(txt, g_font, _fontSize);
			_textHeight = _txts[0].getLocalBounds.height.to!int; // repeats with no effect
			_txts[$ - 1].position = _txts[$ - 1].position + Point(0, i * _textHeight );
		}

		//#not being used
		version(chunk) {
			int i;
			foreach(chunk; chunks(str, chunkSize)) {
				_txts ~= new Text(chunk.to!dstring, g_font, _fontSize);
				_textHeight = _txts[0].getLocalBounds.height.to!int; // repeats with no effect
				_txts[$ - 1].position = _txts[$ - 1].position + Point(0, i * _textHeight);
				i++;
			}
		}
		
		void buildRect() {
			int greatest;
			int index;
			foreach(i, tx; _txts) {
				int rc = tx.getLocalBounds().width.to!int;
				if (rc > greatest) {
					greatest = rc;
					index = i.to!int;
				}
			}
			
			_rect.width = _txts[index].getLocalBounds.width.to!int;
			_rect.height = _txts[0].getLocalBounds.height.to!int * _txts.length.to!int;
		}
		buildRect;
	}
+/		
	void position(float x, float y) {
		foreach(i, txt; _txts) {
			txt.position = Vec(x, y + i * txt.fontSize);
		}
	}
	
	void draw() {
		/+
		if (edge) {
			Text edgeTxt = new Text("", , fontSize);
			edgeTxt.setColor = Color(0, 0, 0);
			foreach(etxt; _txts) {
				edgeTxt.setString = etxt.text;
				float posx = etxt.position.x - 1,
					posy = etxt.position.y - 1;
				foreach(y; 0 .. 3)
					foreach(x; 0 .. 3) {
						edgeTxt.position = Point(posx + x, posy + y);
						g_window.draw(edgeTxt);
					}
			}
		}
		+/
		foreach(txt; _txts) {
			txt.draw;
		}
	}
}
+/