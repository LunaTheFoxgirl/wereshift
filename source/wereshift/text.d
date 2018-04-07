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
module wereshift.text;
import wereshift.iovr;
import polyplex.core;
import polyplex.math;

public class Text {
	private Texture2D font_texture;
	private SpriteBatch sprite_batch;
	private ContentManager manager;
	private Vector2i font_split;

	this(SpriteBatch batcher, ContentManager man, string font_name, Vector2i font_split = Vector2i(10, 10)) {
		this.sprite_batch = batcher;
		this.manager = man;
		this.font_texture = manager.LoadTexture(font_name);
		this.font_split = font_split;
	}

	this(ContentManager man, string font_name, Vector2i font_split = Vector2i(10, 10)) {
		this.manager = man;
		this.font_texture = manager.LoadTexture(font_name);
		this.font_split = font_split;
	}

	private Vector2 get_glyph(char chr) {
		float chr_f = cast(float)chr-48;
		if (chr >= 65) {
			chr_f = cast(float)(chr-65)+10;
		}
		if (chr >= 97) {
			chr_f = cast(float)(chr-97)+10+26;
		}
		return Vector2(chr_f%font_split.X, (chr_f/font_split.Y)%font_split.Y);
	}

	public Vector2 MeasureString(string text, float scale = 1f) {
		Vector2 cursor_pos = Vector2(0, ((font_texture.Height/font_split.Y) - 2f)*scale);
		foreach(char c; text) {
			Vector2 glyph_pos = get_glyph(c);
			cursor_pos += Vector2(((font_texture.Width/font_split.X) - 2f)*scale, 0f);
			if (c == '\n') {
				cursor_pos += Vector2(0f, ((font_texture.Height/font_split.Y) - 2f)*scale);
			}
		}
		return cursor_pos;
	}

	public void DrawString(string text, Vector2 position, float scale = 1f, Color color = Color.White) {
		Vector2 cursor_pos = position;
		foreach(char c; text) {
			Vector2 glyph_pos = get_glyph(c);
			if (c != ' ' && c != '\n')
			sprite_batch.Draw(
				font_texture, 
				new Rectangle(cast(int)cursor_pos.X, cast(int)cursor_pos.Y, (font_texture.Width/font_split.X)*cast(int)scale, (font_texture.Height/font_split.Y)*cast(int)scale),
				new Rectangle(cast(int)glyph_pos.X*(font_texture.Width/font_split.X), cast(int)glyph_pos.Y*(font_texture.Height/font_split.Y), font_texture.Width/font_split.X, font_texture.Height/font_split.Y),
				color);
			cursor_pos += Vector2(((font_texture.Width/font_split.X) - 2f)*scale, 0f);
			if (c == '\n') {
				cursor_pos += Vector2(0f, ((font_texture.Height/font_split.Y) - 2f)*scale);
				cursor_pos = Vector2(position.X, cursor_pos.Y);
			}
		}
	}

	public void DrawString(SpriteBatch sprite_batch, string text, Vector2 position, float scale = 1f, Color color = Color.White) {
		Vector2 cursor_pos = position;
		foreach(char c; text) {
			Vector2 glyph_pos = get_glyph(c);
			if (c != ' ' && c != '\n')
			sprite_batch.Draw(
				font_texture, 
				new Rectangle(cast(int)cursor_pos.X, cast(int)cursor_pos.Y, (font_texture.Width/font_split.X)*cast(int)scale, (font_texture.Height/font_split.Y)*cast(int)scale),
				new Rectangle(cast(int)glyph_pos.X*(font_texture.Width/font_split.X), cast(int)glyph_pos.Y*(font_texture.Height/font_split.Y), font_texture.Width/font_split.X, font_texture.Height/font_split.Y),
				color);
			cursor_pos += Vector2(((font_texture.Width/font_split.X) - 2f)*scale, 0f);
			if (c == '\n') {
				cursor_pos += Vector2(0f, ((font_texture.Height/font_split.Y) - 2f)*scale);
				cursor_pos = Vector2(position.X, cursor_pos.Y);
			}
		}
	}
}