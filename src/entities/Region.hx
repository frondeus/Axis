package entities;

import com.haxepunk.Entity;
import com.haxepunk.masks.Grid;
import com.haxepunk.Sfx;
import com.haxepunk.Graphic;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Tilemap;
import com.haxepunk.graphics.Backdrop;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Emitter;
import com.haxepunk.utils.Input;
import com.haxepunk.utils.Key;
import com.haxepunk.graphics.Text;
import com.haxepunk.HXP;
import haxe.xml.Fast;
import entities.Player;

class Region extends Entity
{
	public function new()
	{
		super(0,0);
		tileW = tileH = 32;

		if(!tiles.exists("city"))
		{
			tiles.set("city","gfx/tiles/city0.png");
			tiles.set("city 10","gfx/tiles/city10.png");
			tiles.set("city 20","gfx/tiles/city20.png");
		}
		sound = null;
		rain = null;
		layer = -5;

		Input.define("any",[Key.ANY]);
	}

	private function addGfx(gfx:Graphic, layer:Int, sY:Bool = false)
	{
		gfx.relative = false;
		var e:Entity = new Entity(0,0,gfx);
		addEntity(e,layer,sY);
	}

	private function addEntity(e:Entity,layer:Int, sY:Bool = false)
	{
		e.layer = layer;
		if(layer > 10 || layer < -10)
		{
			e.graphic.scrollX = 1.0 - (layer * 0.004);
			if(sY) e.graphic.scrollY = e.graphic.scrollX;
		}


		entities.push(e);
	}
	public function reload(player:Player)
	{
		load(lastLvl,player);
	}
	public function load(file:String, player:Player )
	{
		// kod wczytujacy

		_player = player;

		var b:String = openfl.Assets.getText("levels/"+ file + ".xml");
		if(b == null)
			throw "Level does not exist: " + file;

		data = new Fast(Xml.parse(b));
		data = data.node.level;

		if(entities != null)
			HXP.scene.removeList(entities);
		entities = new Array<Entity>();

		 if(data.has.rain)
		{
			rain  = new Emitter( "gfx/particles/rain.png" , 16 , 64 );
			rain.newType("rain",[0]);
			rain.setMotion("rain",270,HXP.screen.height,0.01,0,256,1.0);
			rain.setAlpha("rain",0.5,1.0);
			rain.scrollX = 1.0;
		}
		var st = new String(" press ANY key to continue");
		if(data.hasNode.text)
			st = data.node.text.innerData + "\n\n" + st;
		spawnText  = new Text(st);
		spawnText.x = HXP.halfWidth - (spawnText.textWidth * 0.5);
		spawnText.y = HXP.halfHeight;
		spawnText.scrollX = spawnText.scrollY = 0.0;
		
		graphic = new Graphiclist([rain,spawnText]);

		if(data.hasNode.sfx)
		{
			if(oldSound != data.node.sfx.att.src)
			{
				oldSound = data.node.sfx.att.src;
				if(sound != null) sound.stop();
				sound = new Sfx(data.node.sfx.att.src);
				if(data.node.sfx.att.loop == "true")	sound.loop();
				else 									sound.play();
					
			}
			
		}

		if(data.hasNode.layers)
		{
			for(l in data.node.layers.elements)
			{
				if(l.att.layer == "collision")
					loadMask(l);
				else
					addLayer(l);
			}
		}

		if(data.hasNode.objects)
		{
			for(obj in data.node.objects.elements)
			{
				addObj(obj);
			}
		}
		HXP.scene.addList(entities);

		player.spawn = spawn;
		lastLvl = file;

	}

	public override function update()
	{
		if(	HXP.rate != 1.0 && Input.pressed("any"))
				HXP.rate = 1.0;

		spawnText.visible = (HXP.rate != 1.0);

		var hX = HXP.screen.width / 2;
		var hY = HXP.screen.height / 2;
		for(i in 0 ... 2)
		{
			
			 if(rain != null) rain.emitInRectangle("rain",bLeft,bTop, bLeft + bRight, bTop + 20);
		}
		
				
		if(bRight > HXP.screen.width)
		{
			if (HXP.camera.x < bLeft)
			HXP.camera.x = bLeft;
			else if (HXP.camera.x > bRight - HXP.screen.width)
			HXP.camera.x = bRight - HXP.screen.width;

		}
		if(bBottom > HXP.screen.height)
		{		
			if (HXP.camera.y < bTop)
				HXP.camera.y = bTop;
			else if (HXP.camera.y > bBottom - HXP.screen.height)
				HXP.camera.y = bBottom - HXP.screen.height;
				
		}
		
	}

	public function addObj(obj:Fast)
	{
		var objX = Std.parseInt(obj.att.x);
		var objY = Std.parseInt(obj.att.y);
		var objA = 0.0;
		if(obj.has.angle)
			objA = Std.parseFloat(obj.att.angle);
		var layer = Std.parseInt(obj.att.layer);
		

		switch(obj.name)
		{
			case "spawn":
			{
				spawn  = new flash.geom.Point(objX+16,objY+16);
				return;
			}
			case "exit":
			{
				var e = new entities.Exit(objX,objY,obj.att.where);
				addEntity(e,layer);	
			}
			case "bg":
			{
				switch(obj.att.name)
				{
					case "night":
					{
						var bg = new Image("gfx/bg/sky.png");
						bg.scale = 2.5;
						bg.scrollX = bg.scrollY = 1.0;
						bg.scaledWidth = bRight - bLeft;
						bg.scaledHeight = bBottom - bTop;
						//bg.clipRect = new flash.geom.Rectangle(bLeft,bTop,bRight - bLeft,bBottom - bTop);
						var e:Entity = new Entity(bLeft,bTop,bg);
						e.layer = layer;

						entities.push(e);
					}
				}
				return;
			}
			case "bonus":
			{
				var e = new entities.Bonus(objX,objY);
				addEntity(e,layer);
			}
			case "coin":
			{
				var e = new entities.Coin(objX,objY,Std.parseInt(obj.att.value));
				addEntity(e,layer);
			}
			case "obstacle":
			{
				var e = new entities.Obstacle(objX,objY,objA,obj.att.type);
				addEntity(e,layer);
			}
			case "trap":
			{
				var e = new entities.Trap(objX,objY,objA);
				addEntity(e,layer);
			}
			case "mib":
			{
				var e = new entities.Mib(objX,objY,_player);
				addEntity(e,layer);
			}
		}
		
	}

	public function addLayer(group:Fast)
	{
		var layer:Int = Std.parseInt(group.att.layer);
		var rows:Int = Std.parseInt(group.att.rows);
		var cols:Int = Std.parseInt(group.att.cols);
		var lX:Int = Std.parseInt(group.att.x);
		var lY:Int = Std.parseInt(group.att.y);
		var tile = tiles.get("city");

		if(layer > 10) tile = tiles.get("city 20");
		else if(layer > 0) tile = tiles.get("city 10");

		var map = new Tilemap(tile, tileW * cols ,tileH * rows,tileW,tileH);

		for(obj in group.elements)
		{
			switch(obj.name)
			{
				case "tile":
					map.setTile(Std.parseInt(obj.att.x),
						Std.parseInt(obj.att.y),
						Std.parseInt(obj.att.id));
				case "rect":
					map.setRect(Std.parseInt(obj.att.x),
						Std.parseInt(obj.att.y),
						Std.parseInt(obj.att.w),
						Std.parseInt(obj.att.h),
						Std.parseInt(obj.att.id));
			}
		}
		map.color = HXP.getColorRGB( 254 - (layer * 5) , 254 - (layer * 5) , 254 ); 
		map.alpha = 1.0;
		map.x = lX;
		map.y = lY;
		addGfx(map,layer);
	}

	public function loadMask(group:Fast)
	{
		var rows:Int = Std.parseInt(group.att.rows);
		var cols:Int = Std.parseInt(group.att.cols);
		var lX:Int = Std.parseInt(group.att.x);
		var lY:Int = Std.parseInt(group.att.y);
		
		var mask:Grid = new Grid(tileW * cols, tileH * rows, tileW, tileH);
		
		bTop = lY * tileH;
		bLeft = lX* tileW;
		bRight = cols * tileW;
		bBottom = rows * tileH;

		setHitbox(bRight,bBottom);

		for(obj in group.elements)
		{
			switch(obj.name)
			{
				case "tile":
					mask.setTile(Std.parseInt(obj.att.x),
						Std.parseInt(obj.att.y),
						true);
				case "rect":
					mask.setRect(Std.parseInt(obj.att.x),
						Std.parseInt(obj.att.y),
						Std.parseInt(obj.att.w),
						Std.parseInt(obj.att.h),
						true);
			}
		}

		var e:Entity = new Entity(0,0,null,mask);
		e.type = "solid";
		e.x = lX;
		e.y = lY;
		entities.push(e);
	}

	

	private var rain:Emitter;


	private var tileW:Int;
	private var tileH:Int;
	private var entities:Array<Entity>;

	public var bRight:Int;
	public var bBottom:Int;
	public var bLeft:Int;
	public var bTop:Int;

	private var data:Fast;
	private static var tiles:Map<String,String> = new Map<String,String>();

	private var spawn:flash.geom.Point;
	private var lastLvl:String;

	private var sound:Sfx; 
	private var oldSound:String;

	private var _player:Player;

	private var spawnText:Text;


}