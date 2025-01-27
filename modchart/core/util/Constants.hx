package modchart.core.util;

#if !modchart_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class Constants {
	public static var MODIFIER_LIST:Map<String, Class<Modifier>>;
}

#if !modchart_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:publicFields
@:structInit
class RenderParams {
	var sPos:Float;
	var time:Float;
	var fBeat:Float;
	var hDiff:Float;
	var receptor:Int;
	var field:Int;
	var arrow:Bool;

	// for hold mods
	var __holdParentTime:Float = 0;
	var __holdLength:Float = 0;
	var __holdOffset:Float = 0;
}

#if !modchart_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:publicFields
@:structInit
class ArrowData {
	var time:Float;
	var hDiff:Float;
	var receptor:Int;
	var field:Int;
	var arrow:Bool;

	// for hold mods
	var __holdParentTime:Float = 0;
	var __holdLength:Float = 0;
	var __holdOffset:Float = 0;
}

#if !modchart_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:publicFields
@:structInit
class Visuals {
	var scaleX:Float = 1;
	var scaleY:Float = 1;
	var alpha:Float = 1;
	var zoom:Float = 0;
	var glow:Float = 0;
	var glowR:Float = 1;
	var glowG:Float = 1;
	var glowB:Float = 1;
	var angleX:Float = 0;
	var angleY:Float = 0;
	var angleZ:Float = 0;
	var skewX:Float = 0;
	var skewY:Float = 0;
}

#if !modchart_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
@:publicFields
@:structInit
class Node {
	var input:Array<String> = [];
	var output:Array<String> = [];
	var func:NodeFunction = (_, o) -> _;
}

// (InputModPercents, PlayerNumber) -> OutputModPercents
typedef NodeFunction = (Array<Float>, Int) -> Array<Float>;

#if !modchart_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end
class SimplePoint {
	public var x:Float;
	public var y:Float;

	public function new(x:Float, y:Float) {
		this.x = x;
		this.y = y;
	}
}
