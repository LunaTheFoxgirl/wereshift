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
module wereshift.ui.uiimage;
import wereshift.ui;

public class UIImage : UIElement {
	private Texture2D image;
	private bool place_centered = false;

	public Color ImageColor = Color.White;

	public Vector2i ImageBounds() {
		return Vector2i(image.Width, image.Height);
	}

	this(Rectangle area, UIElement parent, Texture2D image) {
		super(area, parent, null);
		this.image = image;
	}

	public override void Init() {
		if (parent is null) return;
		this.Area = this.Area.Displace(parent.Area.X, parent.Area.Y);
	}

	public void SetPlacement(bool mode) {
		place_centered = mode;
	}

	protected override void update(GameTimes game_time) { }

	protected override void draw(GameTimes game_time, SpriteBatch sprite_batch) {
		Vector2 s = Vector2(image.Width, image.Height);
		Vector2 pos = Vector2(Area.Center.X-(s.X/2), Area.Center.Y-(s.Y/2));
		if (place_centered) sprite_batch.Draw(this.image, new Rectangle(this.Area.X-this.Area.Width/2, this.Area.Y-this.Area.Height/2, this.Area.Width, this.Area.Height), new Rectangle(0, 0, image.Width, image.Height), ImageColor);
		else sprite_batch.Draw(this.image, this.Area, new Rectangle(0, 0, image.Width, image.Height), Color.White);
	}
}