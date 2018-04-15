/*
MIT License

Copyright (c) 2018 Clipsey

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
module wereshift.ui;
public import wereshift.iovr;
public import polyplex.core.content.gl.textures;
public import polyplex.core.content.textures;
public import polyplex.utils.logging;
public import polyplex.core;
public import polyplex.math;

public import wereshift.ui.uielement;
public import wereshift.ui.uibutton;
public import wereshift.ui.uitext;
public import wereshift.ui.uiimage;
public import wereshift.text;

public class UIDesign {
	public static Texture2D UI_TEX;
	public static Text UI_FONT;
	public static Color UI_COL_SELECTED;
	public static Color UI_COLTXT_SELECTED;
	public static Color UI_COL;
	public static Color UI_COLTXT;

	private static bool has_prepped = false;

	public static void PrepareUI(ContentManager manager) {
		if (has_prepped) return;
		UI_TEX = new GlTexture2D(new TextureImg(1, 1, [255, 255, 255, 255]));
		UI_FONT = new Text(manager, "fonts/shramp_sans");
		UI_COL_SELECTED = new Color(204, 204, 204, 255);
		UI_COLTXT_SELECTED = new Color(0, 0, 0, 255);
		UI_COL = new Color(64, 64, 64, 255);
		UI_COLTXT = new Color(255, 255, 255, 255);
		has_prepped = false;
	}
}