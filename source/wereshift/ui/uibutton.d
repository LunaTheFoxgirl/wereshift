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
module wereshift.ui.uibutton;
import wereshift.ui;
import polyplex.core;
import std.stdio;

public class UIButton : UIElement {
	alias ButtonCallback = void delegate();
	private ButtonCallback callback;
	private bool hovering = false;
	private string text;

	private static MouseState current_state;
	private static MouseState last_state;

	this(Rectangle area, UIElement parent, string text, string tooltip = null) {
		super(area, parent, tooltip);
		this.text = text;
	}

	~this() {
		callback = null;
	}

	public UIButton SetCallback(ButtonCallback callback) {
		this.callback = callback;
		return this;
	}

	public override void Init() {
		if (parent is null) return;
		this.Area.Displace(parent.Area.X, parent.Area.Y);
	}

	public static void MouseUpdateBegin() {
		current_state = Mouse.GetState();
		if (last_state is null) last_state = current_state;
	}

	public static void MouseUpdateEnd() {
		last_state = current_state;
	}

	protected override void update(GameTimes game_time) {
		hovering = false;
		if (this.Area.Intersects(Mouse.Position)) {
			hovering = true;
			if (current_state.IsButtonPressed(MouseButton.Left) && last_state.IsButtonReleased(MouseButton.Left))
				callback();
		}
	}

	protected override void draw(GameTimes game_time, SpriteBatch sprite_batch) {
		if (hovering) sprite_batch.Draw(UIDesign.UI_TEX, this.Area, new Rectangle(0, 0, 1, 1), UIDesign.UI_COL_SELECTED);
		else sprite_batch.Draw(UIDesign.UI_TEX, this.Area, new Rectangle(0, 0, 1, 1), UIDesign.UI_COL);

		Vector2 s = UIDesign.UI_FONT.MeasureString(this.text, 1f);
		Vector2 pos = Vector2(Area.Center.X-(s.X/2), Area.Center.Y-(s.Y/2));

		if (this.Area.Width < s.X) {
			this.Area.Width = cast(int)s.X;
		}

		if (this.Area.Height < s.Y) {
			this.Area.Height = cast(int)s.Y;
		}

		if (hovering) UIDesign.UI_FONT.DrawString(sprite_batch, this.text, pos, 1f, UIDesign.UI_COLTXT_SELECTED);
		else UIDesign.UI_FONT.DrawString(sprite_batch, this.text, pos, 1f, UIDesign.UI_COLTXT);
	}
}