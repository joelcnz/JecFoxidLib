//#more work here?
//#dummy I think
module jecfoxid.gui;

import jecfoxid;

/// Root wedget
class Wedget {
//private:
    WedgetType _wedgetType;

    /// name id
    string _nameid; 
    /// box or button dimentions
    JRectangle _box;
    /// Focus box
    JRectangle _rectOutLineShp;
    /// box or button graphic
    JRectangle _rectFillShp;
    /// box, button, icon, mouse over status
    Focus _focus;
    /// Font
    //TTF_Font* _font;
    /// Text
    JText _listTxt;
    /// My input text
    InputJex _input;
    /// List of text strings
    string[] _list;
    /// Show or hide
    bool _hidden;
    /// Does is show the focus outline with the mouse pointer
    bool _focusAble = true;
public:
    /// name
    auto nameid() { return _nameid; }
    /// box
    auto box() { return _box; }
    /// 1st text of strings setter
    void txtHead(string txt0) {
        if (_list.length)
            _list[0] = txt0;
        //#more work here?
    }
    /// 1st text of strings setter
    auto txtHead() { 
        if (_list.length)
            return _list[0];
        return "?";
    }
    /// list getter
    auto list() { return _list; }
    /// list setter
    void list(string[] list0) { _list = list0; }
    /// Input getter
    auto input() { return _input; }
    /// hide setter
    void hidden(bool hidden0) { _hidden = hidden0; } 
    /// hide getter
    auto hidden() { return _hidden; }
    /// Setter whether focusable or not
    void focusAble(bool focusAble0) { _focusAble = focusAble0; }
    /// focusable getter
    auto focusAble() { return _focusAble; }

    /// Ctor name and box (location and size)
    this(in string nameid0, in JRectangle box0) {
        _wedgetType = WedgetType.wedget;
        _nameid = nameid0;
        _box = box0;
        _rectFillShp = box0;
        _rectFillShp.col = Color(180, 64, 0);
        _rectOutLineShp = box0;
        //_rectOutLineShp.mColour = SDL_Color(255,255,255, 0xFF);
        //_font = TTF_OpenFont(buildPath("Fonts", "DejaVuSans.ttf").toStringz, 15);
        //assert(_font, "Font load fail");
       
       // _listTxt = Jexting( "", SDL_Rect(0,0,0,0), SDL_Color(255,255,0,0xFF), 15,
       //     buildPath("Fonts", "DejaVuSans.ttf"));
       _listTxt = JText("",gFont);

        _list ~= nameid; //#dummy I think
        //_font = TTF_OpenFont("DejaVuSans.ttf".toStringz, 15);
        //assert(_font, "Font not set");
    }

    void close() {
        //_listTxt.close;
        //TTF_CloseFont(_font);
    }

    /// Check for focus
    bool gotFocus(Vec pos) {
        import std.string : split;
        //mixin(trace("_box.x _box.y _box.w _box.h".split));
        if (! hidden && pos.x >= _box.pos.x && pos.x < _box.pos.x + _box.size.x &&
            pos.y >= _box.pos.y && pos.y < _box.pos.y + _box.size.y)
            return true;
        return false;
    }

    /// Position filler
    void process() {}

    /// Minimal drawing
    void draw(Display graph) {
        graph.drawRect(_rectFillShp.pos,_rectFillShp.pos + _rectFillShp.size,_rectFillShp.col,true); // Drawning rectangle
        /+
        SDL_SetRenderDrawColor(gRenderer,
            _rectFillShp.mColour.r,
            _rectFillShp.mColour.g,
            _rectFillShp.mColour.b, 0xFF);
        SDL_RenderFillRect(gRenderer, &_rectFillShp.mRect);
+/
        if (_wedgetType != WedgetType.edit && _list.length) {
            auto pos = Vec(box.pos.x + 1, box.pos.y + 1);
            foreach(item; _list) {
                _listTxt.text = item;
                _listTxt.position = pos;
                _listTxt.draw(graph);
                pos.y += _listTxt.font.size; //Vec(pos.X, pos.Y + _listTxt.mRect.h);
            }
        }
        if (focusAble && _focus == Focus.on) {
  //          SDL_SetRenderDrawColor(gRenderer, 0xFF, 0xFF, 0xFF, 0xFF);
//            SDL_RenderDrawRect(gRenderer, &_rectOutLineShp.mRect);
            graph.drawRect(_rectOutLineShp.pos,_rectOutLineShp.pos + _rectOutLineShp.size,Clr.white,false);
        }
    }
}

/// Edit box wedget
class EditBox : Wedget {
    /// Ctor name, boc, and label
    this(in string name, in JRectangle box0, string txt0) {
        super(name, box0);
        _wedgetType = WedgetType.edit;
       _input = new InputJex(/* position */ Vec(_box.pos.x + 2, box.pos.y + 2),
                    /* font size */ 12,
                    /* header */ txt0,
                    /* Type (oneLine, or history) */ InputType.oneLine);
        _input.setColour(Color(0xFF, 0xFF, 0xFF, 0xFF));
    }

    override void process() {
        with(_input) {
            if (_focus == Focus.on) {
                    process; //#input
                    drawCursor = true;
            } else
                drawCursor = false;
        }
    }

    override void draw(Display graph) {
        super.draw(graph);
        _input.draw(graph);
    }
}

/// Button wedget
class Button : Wedget {
    /// Ctor name, box, and text for button
    this(in string name, in JRectangle box0, string txt0) {
        super(name, box0);
        _wedgetType = WedgetType.button;
    }

    override void process() {
    }

    override void draw(Display graph) {
        super.draw(graph);
    }
}
