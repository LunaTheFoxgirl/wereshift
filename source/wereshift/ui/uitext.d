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
module wereshift.ui.uitext;
import wereshift.ui;

public class UILabel : UIElement {
	private string text;
	private Color background_color;
	private Color foreground_color;
	private bool hovering = false;
	private float size = 1f;

	this(Rectangle area, UIElement parent, string text = "Label", float size = 1f, Color bg_color = Color.Transparent, Color fg_color = Color.White) {
		super(area, parent, null);
		this.text = text;
		this.background_color = bg_color;
		this.foreground_color = fg_color;
		this.size = size;
	}

	public override void Init() {
		if (parent is null) return;
		this.Area.Displace(parent.Area.X, parent.Area.Y);
	}

	protected override void update(GameTimes game_time) { }

	protected override void draw(GameTimes game_time, SpriteBatch sprite_batch) {
		Vector2 s = UIDesign.UI_FONT.MeasureString(this.text, this.size);
		Vector2 pos = Vector2(Area.X, Area.Y);
		if (this.Area.Width < s.X) {
			this.Area.Width = cast(int)s.X;
		}
		if (this.Area.Height < s.Y) {
			this.Area.Height = cast(int)s.Y;
		}
		if (background_color.Alpha > 0) sprite_batch.Draw(UIDesign.UI_TEX, this.Area, new Rectangle(0, 0, 1, 1), background_color);
		UIDesign.UI_FONT.DrawString(sprite_batch, this.text, pos, this.size, this.foreground_color);
	}
}