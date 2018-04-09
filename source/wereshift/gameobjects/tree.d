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
module wereshift.gameobjects.tree;
import wereshift.gameobject;
import wereshift.game;
import wereshift.random;

private enum TreeType {
	Birch = 0,
	Pine = 1,
	AppleTree = 2,
	Dead = 3
}

public class Tree : GameObject {
	// Looks
	private static Texture2D TreeTexture;
	private static Random rng;
	private TreeType type;

	// Collission
	public Rectangle Hitbox;

	this(Level parent, Vector2 spawn_point) {
		super(parent, spawn_point);
	}

	public override void LoadContent(ContentManager content) {
		if (TreeTexture is null) TreeTexture = content.LoadTexture("terrain/trees");
		if (rng is null) rng = new Random();
		type = cast(TreeType)rng.Next(0, 4);
		this.Hitbox = new Rectangle(cast(int)this.spawn_point.X+201, -512, 60, 512);
	}

	public override void Update(GameTimes game_time) {
		if (parent.ThePlayer.Hitbox.Intersects(this.Hitbox)) {
			parent.ThePlayer.Shade();
		}
	}

	public override void Draw(GameTimes game_time, SpriteBatch sprite_batch) {
		sprite_batch.Draw(TreeTexture, 
			new Rectangle(cast(int)spawn_point.X, cast(int)spawn_point.Y-TreeTexture.Height, TreeTexture.Width/4, TreeTexture.Height), 
			new Rectangle(cast(int)type*(TreeTexture.Width/4), 0, TreeTexture.Width/4, TreeTexture.Height), 
			Color.White);
	}
}