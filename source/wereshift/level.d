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
module wereshift.level;
import wereshift.entity;
import wereshift.entities;

public class LevelGenerator {
	private EntityFactory[] entity_generators;

}

public class Level {
	public Player ThePlayer;
	public Entity[] Entities;

	private ContentManager manager;

	this(ContentManager manager) {
		this.manager = manager; 
	}

	public void Generate() {
		ThePlayer = new Player();
	}

	public void Init() {
		foreach(Entity e; Entities) {
			if (!(e is null))
				e.LoadContent(manager);
		}
	}

	public void Update(GameTime game_time) {
		foreach(Entity e; Entities) {
			if (!(e is null))
				e.Update(game_time);
		}
	}

	public void Draw(GameTime game_time) {
		foreach(Entity e; Entities) {
			if (!(e is null))
				e.Draw(game_time);
		}
	}
}