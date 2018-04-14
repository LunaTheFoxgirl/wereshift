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
module wereshift.gameobjects.projectile;
import wereshift.gameobjects;
import wereshift.gameobject;
import wereshift.animation;
import wereshift.game;

import std.stdio;

enum ProjectileType {
	Bullet,
	Arrow
}

public class Projectile : GameObject {
	public static Texture2D BulletTex;
	public static Texture2D ArrowTex;
	// TODO: Finish this.

	private float gravity = 0.6f;
	private SpriteFlip flip = SpriteFlip.None;

	private Vector2 velocity;
	private Vector2 position;
	private Vector2i hits;	
	public Rectangle Hitbox;
	public Rectangle Drawbox;

	public ProjectileType ProjType;

	public bool Spent = false;

	this(Level level, Vector2 spawn_point, ProjectileType type, Vector2 velocity) {
		super(level, spawn_point);
		this.position = spawn_point;
		this.ProjType = type;
		this.velocity = velocity;
	}

	public override void LoadContent(ContentManager manager) {
		//if (BulletTex is null) BulletTex = manager.LoadTexture("projectiles/bullet");
		if (ArrowTex is null) ArrowTex = manager.LoadTexture("projectiles/arrow");

		//this.hits = Vector2i(BulletTex.Width, BulletTex.Height);
		if (ProjType == ProjectileType.Arrow) {
			this.hits = Vector2i(ArrowTex.Width, ArrowTex.Height);
		}
	}

	public override void Update(GameTimes game_time) {
		this.position += velocity/2;

		// If it's an arrow, apply gravity to it
		if (ProjType == ProjectileType.Arrow) this.velocity += Vector2(0, gravity/2);

		if (this.position.Y > 0) {
			this.velocity = Vector2.Zero;
			this.Spent = true;
		}

		Vector2i s = Vector2i(this.hits.X*4, this.hits.Y*4);

		this.Hitbox = new Rectangle(cast(int)position.X+(s.X/2)-((s.X/2)/4), cast(int)position.Y+(s.Y/2)-((s.Y/2)/4), (s.X/4), (s.Y/4));
		this.Drawbox = new Rectangle(cast(int)position.X, cast(int)position.Y, s.X, s.Y);

		if (Spent) return;
		if (this.Hitbox.Intersects(parent.ThePlayer.Hitbox)) {
			parent.ThePlayer.Damage(20);
			this.Spent = true;
			this.velocity = Vector2.Zero;
		}

		Vector2 normDir = velocity.Normalize;
		rot = cast(float)(Mathf.ATan2(normDir.Y, normDir.X));
		flip = SpriteFlip.FlipVertical;
	}
	float rot = 0f;
	public override void Draw(GameTimes game_time, SpriteBatch sprite_batch) {
		//if (ProjType == ProjectileType.Arrow) {
		//sprite_batch.Draw(parent.BoxTex, Hitbox, new Rectangle(0, 0, 1, 1), Color.MonoGameOrange, flip);
		sprite_batch.Draw(ArrowTex, Drawbox, new Rectangle(0, 0, ArrowTex.Width, ArrowTex.Height), rot, Vector2(ArrowTex.Width/2, ArrowTex.Height/2), Color.White, flip);
		//	return;
		//}
		//sprite_batch.Draw(BulletTex, Hitbox, new Rectangle(0, 0, BulletTex.Width, BulletTex.Height), rot, Vector2(BulletTex.Width/2, BulletTex.Height/2), Color.Yellow);
	}
}