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
module wereshift.gameobjects.ground;
import wereshift.gameobject;
import wereshift.animation;
import wereshift.game;

public class Ground : GameObject {
	public Texture2D GroundTexture;

	this(Level parent) {
		super(parent, Vector2(0, 0));
	}

	public override void LoadContent(ContentManager content) {
		this.GroundTexture = content.LoadTexture("terrain/ground");	
	}

	public override void Update(GameTimes game_time) {

	}

	public override void Draw(GameTimes game_time, SpriteBatch sprite_batch) {
		foreach (i; 0 .. parent.LevelSize) {
			SpriteFlip flip = SpriteFlip.None;
			if (i % 2 == 0) flip = SpriteFlip.FlipVertical;
			sprite_batch.Draw(GroundTexture, 
				new Rectangle(i*GroundTexture.Width, -32, GroundTexture.Width, GroundTexture.Height), 
				new Rectangle(0, 0, GroundTexture.Width, GroundTexture.Height), 
				Color.White, flip);
		}
	}
}