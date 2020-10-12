module jecfoxid.setup;

import jecfoxid;

bool jf_setup(in string title = "Jec Foxid", int windowWidth = 640, int windowHeight = 480, Color clearColour = Color(0,0,0)) @trusted {
	sdlInit(); // Initialize sdl 2.
	_foxloader = new Loader();
	_foxscene = new SceneManager();
	//_listener = new Listener();
	_window = new Window();
	_window.create(windowWidth,windowHeight,title);
	_window.background = clearColour; //Clr.black;

	assert(window !is null);
	assert(window.sdlWindow !is null);
	assert(window.sdlRender !is null);
	assert(_foxloader !is null);

	gWin = _window;
	gGraph = new Display(gWin); // We create and tell the display that we are drawing into this window.
	assert(jf_initKeys, "keys failure");
	gFont = new Font();
	immutable fontFileName = "fonts/DejaVuSans.ttf";
	gFont.load(fontFileName,gFontSize);
	guiSetup;

	return true;
}

//bool initKeys() @trusted {
	//}
bool jf_initKeys() @trusted {
	g_keystate = SDL_GetKeyboardState(null);
	foreach(tkey; cast(SDL_Scancode)0 .. SDL_NUM_SCANCODES)
		g_keys ~= new TKey(cast(SDL_Scancode)tkey);

	return g_keys.length == SDL_NUM_SCANCODES;
}

void guiSetup() {
	auto col = SDL_Color(0xFF, 0xFF, 0, 0xFF);

	auto test = new Wedget("projects", JRectangle(SDL_Rect(20,20,300,400), BoxStyle.solid, col));

	int take = 100;
	g_guiFile.setup([
		new Wedget("projects", JRectangle(SDL_Rect(20,20,300,400 - take), BoxStyle.solid, col)),
		new EditBox("save", JRectangle(SDL_Rect(20,425 - take,300,20), BoxStyle.solid, col), "Save name: "),
		new EditBox("load", JRectangle(SDL_Rect(20,450 - take,300,20), BoxStyle.solid, col), "Load name: "),
		new EditBox("rename", JRectangle(SDL_Rect(20,475 - take,300,20), BoxStyle.solid, col), "Rename: "),
		new EditBox("delete", JRectangle(SDL_Rect(20,500 - take,300,20), BoxStyle.solid, col), "Delete name: "),
		new Wedget("current", JRectangle(SDL_Rect(20,525 - take,300,20), BoxStyle.solid, col))
		]);
	g_guiFile.getWedgets[WedgetFile.projects].focusAble = false;
	g_guiFile.getWedgets[WedgetFile.current].focusAble = false;
	
	int xpos = 320;
	g_guiConfirm.setup([
		new Wedget("sure", JRectangle(SDL_Rect(xpos + 20,20,300,60), BoxStyle.solid, col)),
		new Button("no", JRectangle(SDL_Rect(xpos + 20,85,140,20), BoxStyle.solid, col), "No"),
		new Button("yes", JRectangle(SDL_Rect(xpos + 20 + 160,85,140,20), BoxStyle.solid, col), "Yes"),
	]);
	g_guiConfirm.getWedgets[StateConfirm.ask].focusAble = false;
}

//Frees media and shuts down SDL
void close()
{
	//if (gFont) TTF_CloseFont(gFont);
	/+
	//Destroy window
	SDL_DestroyWindow( gWindow );

	//Destroy texture
	SDL_DestroyTexture(gTexture);

	if (gFont) TTF_CloseFont(gFont);

	gSndCtrl.onCleanup;

	//Quit SDL subsystems
	SDL_Quit();
	IMG_Quit();
	TTF_Quit();
	SDL_AudioQuit();
	+/
}
