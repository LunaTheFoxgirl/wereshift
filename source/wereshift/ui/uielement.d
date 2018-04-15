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
module wereshift.ui.uielement;
import wereshift.ui;

public class UIElement {
	public Rectangle Area;
	protected UIElement parent;
	private string tooltip;
	private UILabel label;

	this(Rectangle area, UIElement parent = null, string tooltip = null) {
		this.Area = area;
		this.parent = parent;
		this.tooltip = tooltip;
		if (!(tooltip is null)) this.label = new UILabel(new Rectangle(0, 0, 1, 1), null, tooltip, 0.6f, UIDesign.UI_COL);
	}

	public void Update(GameTimes game_time) {
		update(game_time);
	}

	public void Draw(GameTimes game_time, SpriteBatch sprite_batch) {
		draw(game_time, sprite_batch);
		if (!(this.label is null)) {
			if (this.Area.Intersects(Mouse.Position)) {
				label.Area = new Rectangle(cast(int)Mouse.Position.X+16, cast(int)Mouse.Position.Y+16, 1, 1);
				label.Draw(game_time, sprite_batch);
			}
		}
	}

	public abstract void Init();
	protected abstract void draw(GameTimes game_time, SpriteBatch sprite_batch);
	protected abstract void update(GameTimes game_time);
}