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

		objects = new Map<Int,entities.Usable>();
		sound = null;
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

		var b:String = openfl.Assets.getText("levels/"+ file + ".xml");
		if(b == null)
			throw "Level does not exist: " + file;

		data = new Fast(Xml.parse(b));
		data = data.node.level;

		if(entities != null)
			HXP.scene.removeList(entities);
		entities = new Array<Entity>();

		// if(data.has.background)
		{
			rain  = new Emitter( "gfx/particles/rain.png" , 16 , 64 );
			rain.newType("rain",[0]);
			rain.setMotion("rain",270,HXP.screen.height,0.01,0,256,1.0);
			rain.setAlpha("rain",0.5,1.0);
			rain.layer = -100;
			rain.scrollX = 0.0;

			graphic = new Graphiclist([rain,]);
		}

		if(data.hasNode.sfx)
		{
			if(oldSound != data.node.sfx.att.src)
			{
				oldSound = data.node.sfx.att.src;
				if(sound != null) sound.stop();
				sound = new Sfx(data.node.sfx.att.src);
				if(data.node.sfx.att.loop == "true")
				{
					sound.loop();
				}
				else
				{
					sound.play();
				}		
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

		if(data.hasNode.links)
		{
			for(link in data.node.links.elements)
			{
				addLink(link);
			}
		}

		

		// Objects

		// Doors and Stairways.

		
		HXP.scene.addList(entities);

		player.spawn = spawn;
		lastLvl = file;

	}

	public override function update()
	{
		var hX = HXP.screen.width / 2;
		var hY = HXP.screen.height / 2;
		for(i in 0 ... 2)
		{
			
			 rain.emitInRectangle("rain",0,HXP.camera.y, HXP.screen.width * 2, 20);
		}
		
		{
			
			
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
	}

	public function addObj(obj:Fast)
	{
		var objX = Std.parseInt(obj.att.x);
		var objY = Std.parseInt(obj.att.y);
		var objA = 0.0;
		if(obj.has.angle)
			objA = Std.parseFloat(obj.att.angle);
		var layer = Std.parseInt(obj.att.layer);
		var e:Entity = null;

		switch(obj.name)
		{
			case "door":
			{
				var locked:Bool = (obj.att.locked == "true");
				e= new entities.Exit(objX,objY,locked);
				addEntity(e,layer);
			}
			case "way":
			{
				if(obj.att.enter == "true")	//Spawn point
				{
					spawn  = new flash.geom.Point(objX+16,objY+16);
					return;
				}
				else
				{
					e = new entities.Aim(objX,objY,obj.att.where);
					addEntity(e,layer);
				}
			}
			case "tree":
			{
				e = new Entity(objX,objY,new Image("gfx/entities/drzewo.png"));
				addEntity(e,layer);
			}
			case "tree2":
			{
				e = new Entity(objX,objY,new Image("gfx/entities/drzewo2.png"));
				addEntity(e,layer);
			}
			case "bg":
			{
				switch(obj.att.name)
				{
					case "night":
					{
						addGfx(new Backdrop("gfx/bg/sky.png",true,true),layer,true);
						addGfx(new Backdrop("gfx/bg/sky2.png",true,true),layer-1,true);
						addGfx(new Backdrop("gfx/bg/sky3.png",true,true),layer-2,true);
					}
					case "clouds":
					{
						addGfx(new Backdrop("gfx/bg/clouds.png",true,true),layer,true);
					}
					case "lights":
					{
						addGfx(new Backdrop("gfx/bg/sun.png",true,false),layer,true);
					}
				}
				return;
			}
			case "bonus":
			{
				e = new entities.Coin(objX,objY,100);//TODO
				addEntity(e,layer);
			}
			case "coin":
			{
				e = new entities.Coin(objX,objY,Std.parseInt(obj.att.value));
				addEntity(e,layer);
			}
			case "obstacle":
			{
				e = new entities.Obstacle(objX,objY,objA,obj.att.type);
				addEntity(e,layer);
			}
			case "mib":
			{
				e = new entities.Mib(objX,objY);
				addEntity(e,layer);
			}
		}
		if(e == null) haxe.Log.trace("NULL");
		if(obj.has.id && e != null)
		{
			var id = Std.parseInt(obj.att.id);
			objects.set(id,cast e);
		}
		
	}

	public function addLink(link:Fast)
	{

		var from = Std.parseInt(link.att.from);
		var to = Std.parseInt(link.att.to);
		if(objects.exists(from) && objects.exists(to))
		{
			objects.get(from).links.push(objects.get(to));
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
	private var objects:Map<Int,entities.Usable>;

	private var spawn:flash.geom.Point;
	private var lastLvl:String;

	private var sound:Sfx; 
	private var oldSound:String;


}