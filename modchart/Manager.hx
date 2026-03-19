package modchart;

import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.tweens.FlxEase.EaseFunction;
import flixel.util.FlxSort;
import haxe.ds.Vector;
import modchart.backend.core.ArrowData;
import modchart.backend.core.ModifierParameters;
import modchart.backend.core.Node.NodeFunction;
import modchart.backend.core.VisualParameters;
import modchart.backend.graphics.CtxRenderer;
import modchart.backend.graphics.DrawCommand;
import modchart.backend.graphics.renderers.*;
import modchart.backend.util.ModchartUtil;
import modchart.engine.modifiers.list.*;
import modchart.events.*;
import modchart.events.types.*;

/**
 * This assembles the modchart components, including:
 * - PlayFields
 * - Event Timeline
 * - Rendering
 */
@:allow(modchart.backend.ModifierGroup)
@:access(modchart.engine.PlayField)
#if !openfl_debug
@:fileXml('tags="haxe,release"') @:noDebug
#end
final class Manager extends FlxBasic {
	/**
	 * Instance of the Manager.
	 */
	public static var instance:Manager;

	/**
	 * Flag to enable or disable rendering of arrow paths.
	 * `Deprecated`
	 */
	@:deprecated("Use `Config.RENDER_ARROW_PATHS` instead.")
	public var renderArrowPaths:Bool = false;

	/**
	 * List of playfields managed by the Manager.
	 */
	public var playfields:Array<PlayField> = [];

	/**
	 * List of playfields managed by the Manager.
	 */
	public var proxies:Array<Proxy> = [];

	private var renderer:CtxRenderer;

	public function new() {
		super();

		instance = this;
		renderer = new CtxRenderer();

		Adapter.init();
		Adapter.instance.onModchartingInitialization();

		addPlayfield();
	}

	/**
	 * Internal helper function to apply a function to each playfield.
	 *
	 * @param func The function to apply to each playfield.
	 * @param player Optionally, the specific player to target (-1 for all).
	 */
	public inline function iteratePlayfields(func:PlayField->Void, player:Int = -1) {
		// If there's only one playfield or a specific player is provided, apply the function directly
		if (playfields.length == 1 && player != -1)
			return func(playfields[player != -1 ? player : 0]);

		// Otherwise, apply the function to all playfields
		for (i in 0...playfields.length)
			func(playfields[i]);
	}

	/**
	 * Adds a modifier for all playfields or a specific one.
	 *
	 * @param name The name of the modifier.
	 * @param field Optionally, the specific playfield to target.
	 */
	public inline function addModifier(name:String, field:Int = -1)
		iteratePlayfields((pf) -> pf.addModifier(name), field);

	/**
	 * Adds a scripted modifier for all playfields or a specific one.
	 *
	 * @param name The name of the modifier.
	 * @param instance The instance of the modifier.
	 * @param field Optionally, the specific playfield to target.
	 */
	public inline function addScriptedModifier(name:String, instance:Modifier, field:Int = -1)
		iteratePlayfields((pf) -> pf.addScriptedModifier(name, instance), field);

	/**
	 * Sets the percent for a specific modifier for all playfields or a specific one.
	 *
	 * @param name The name of the modifier.
	 * @param value The percent value to set.
	 * @param player Optionally, the player to target.
	 * @param field Optionally, the specific playfield to target.
	 */
	public inline function setPercent(name:String, value:Float, player:Int = -1, field:Int = -1)
		iteratePlayfields((pf) -> pf.setPercent(name, value, player), field);

	/**
	 * Gets the percent for a specific modifier.
	 *
	 * @param name The name of the modifier.
	 * @param player The player to target.
	 * @param field Optionally, the specific playfield to target.
	 * @return The percent value for the modifier.
	 */
	public inline function getPercent(name:String, player:Int = 0, field:Int = 0):Float {
		final possiblePlayfield = playfields[field];

		if (possiblePlayfield != null)
			return possiblePlayfield.getPercent(name, player);

		return 0.;
	}

	/**
	 * Adds an event to all playfields or a specific one.
	 *
	 * @param event The event to add.
	 * @param field Optionally, the specific playfield to target.
	 */
	public inline function addEvent(event:Event, field:Int = -1)
		iteratePlayfields((pf) -> pf.addEvent(event), field);

	/**
	 * Sets a specific value at a certain beat for all playfields or a specific one.
	 *
	 * @param name The name of the value.
	 * @param beat The beat at which the value should be set.
	 * @param value The value to set.
	 * @param player Optionally, the player to target.
	 * @param field Optionally, the specific playfield to target.
	 */
	public inline function set(name:String, beat:Float, value:Float, player:Int = -1, field:Int = -1)
		iteratePlayfields((pf) -> pf.set(name, beat, value, player), field);

	/**
	 * Applies easing to a modifier.
	 *
	 * @param name The name of the modifier.
	 * @param beat The beat at which to start easing.
	 * @param length The length of the easing.
	 * @param value The final value after easing.
	 * @param easeFunc The easing function to use.
	 * @param player Optionally, the player to target.
	 * @param field Optionally, the specific playfield to target.
	 */
	public inline function ease(name:String, beat:Float, length:Float, value:Float = 1, easeFunc:EaseFunction, player:Int = -1, field:Int = -1)
		iteratePlayfields((pf) -> pf.ease(name, beat, length, value, easeFunc, player), field);

	/**
	 * Adds easing to a modifier.
	 *
	 * @param name The name of the modifier.
	 * @param beat The beat at which to start easing.
	 * @param length The length of the easing.
	 * @param value The value to apply after easing.
	 * @param easeFunc The easing function to use.
	 * @param player Optionally, the player to target.
	 * @param field Optionally, the specific playfield to target.
	 */
	public inline function add(name:String, beat:Float, length:Float, value:Float = 1, easeFunc:EaseFunction, player:Int = -1, field:Int = -1)
		iteratePlayfields((pf) -> pf.add(name, beat, length, value, easeFunc, player), field);

	/**
	 * Sets and adds a value to a modifier.
	 *
	 * @param name The name of the modifier.
	 * @param beat The beat at which the value should be set.
	 * @param value The value to set.
	 * @param player Optionally, the player to target.
	 * @param field Optionally, the specific playfield to target.
	 */
	public inline function setAdd(name:String, beat:Float, value:Float, player:Int = -1, field:Int = -1)
		iteratePlayfields((pf) -> pf.setAdd(name, beat, value, player), field);

	/**
	 * Adds a repeater event for all playfields or a specific one.
	 *
	 * @param beat The beat at which the repeater starts.
	 * @param length The length of the repeat action.
	 * @param callback The callback function to execute.
	 * @param field Optionally, the specific playfield to target.
	 */
	public inline function repeater(beat:Float, length:Float, callback:Event->Void, field:Int = -1)
		iteratePlayfields((pf) -> pf.repeater(beat, length, callback), field);

	/**
	 * Adds a callback event for all playfields or a specific one.
	 *
	 * @param beat The beat at which the callback will be triggered.
	 * @param callback The callback function to execute.
	 * @param field Optionally, the specific playfield to target.
	 */
	public inline function callback(beat:Float, callback:Event->Void, field:Int = -1)
		iteratePlayfields((pf) -> pf.callback(beat, callback), field);

	/**
	 * Creates a node linking inputs and outputs to a function.
	 *
	 * @param input The list of input names.
	 * @param output The list of output names.
	 * @param func The function to execute for the node.
	 * @param field Optionally, the specific playfield to target.
	 */
	public inline function node(input:Array<String>, output:Array<String>, func:NodeFunction, field:Int = -1)
		iteratePlayfields((pf) -> pf.node(input, output, func), field);

	/**
	 * Creates an alias for a given modifier.
	 *
	 * @param name The original modifier name.
	 * @param alias The alias name.
	 * @param field The specific playfield to apply the alias to.
	 */
	public inline function alias(name:String, alias:String, field:Int)
		iteratePlayfields((pf) -> pf.alias(name, alias), field);

	/**
	 * Creates and adds a new playfield to the list.
	 */
	public inline function addPlayfield()
		appendPlayfield(new PlayField());

	/**
	 * Adds a playfield to the list.
	 */
	public inline function appendPlayfield(playfield:PlayField) {
		playfield.ID = playfields.length;
		playfields.push(playfield);
	}

	/**
	 * Adds a proxy to the list.
	 */
	public inline function appendProxy(proxy:Proxy) {
		proxies.push(proxy);
	}

	/**
	 * Updates all playfields in the game loop.
	 *
	 * @param elapsed The time elapsed since the last update.
	 */
	override function update(elapsed:Float):Void {
		super.update(elapsed);

		iteratePlayfields(pf -> pf.update(elapsed));
	}

	/**
	 * Draws all playfields.
	 */
	override function draw():Void {
		var playerItems:Array<Array<Array<FlxSprite>>> = Adapter.instance.getArrowItems();

		if (playerItems == null)
			return;
		renderer.emit(playerItems, playfields, proxies);
	}

	/**
	 * Destroys all playfields and cleans up.
	 */
	override function destroy():Void {
		super.destroy();

		Adapter.instance.onModchartingDispose();

		iteratePlayfields(pf -> {
			pf.destroy();
		});
	}

	// Constants for hold and arrow sizes
	public static var HOLD_SIZE:Float = 50 * 0.7;
	public static var HOLD_SIZEDIV2:Float = (50 * 0.7) * 0.5;
	public static var ARROW_SIZE:Float = 160 * 0.7;
	public static var ARROW_SIZEDIV2:Float = (160 * 0.7) * 0.5;
}
