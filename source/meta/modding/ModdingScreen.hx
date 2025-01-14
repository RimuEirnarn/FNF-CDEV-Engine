package meta.modding;

import flixel.FlxState;
import flixel.ui.FlxButton;
import openfl.Lib;
import game.Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
#if desktop
import game.cdev.engineutils.Discord.DiscordClient;
#end
import game.objects.Alphabet;
import game.cdev.*;
import game.*;

class ModdingScreen extends meta.states.MusicBeatState
{
	var options:Array<String> = ["Add a new song" ,'Character Editor', 'Stage Editor', 'Week Editor'/*, 'Add Event Script' no*/];
	var curSelected:Int = 0;
	var grpMenu:FlxTypedGroup<Alphabet>;
	var menuBG:FlxSprite;

	override function create()
	{
		Paths.currentMod = Paths.curModDir[0];
		FlxG.sound.muteKeys = [ZERO, NUMPADZERO];
		FlxG.sound.volumeDownKeys = [MINUS, NUMPADMINUS];
		FlxG.sound.volumeUpKeys = [PLUS, NUMPADPLUS];
		#if desktop
		if (Main.discordRPC)
			DiscordClient.changePresence("Creating a mod", Paths.curModDir[0]);
		#end

		menuBG = new FlxSprite().loadGraphic(Paths.image('menuDesat', 'preload'));
		menuBG.color = 0xff0088ff;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.alpha = 0.5;
		menuBG.antialiasing = CDevConfig.saveData.antialiasing;
		add(menuBG);

		grpMenu = new FlxTypedGroup<Alphabet>();
		add(grpMenu);

		for (i in 0...options.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, options[i], true, false);
			songText.isMenuItem = true;
			songText.isFreeplay = true;
			songText.targetY = i;
			grpMenu.add(songText);
		}
		changeSelection();

		var bottomPanel:FlxSprite = new FlxSprite(0, FlxG.height - 70).makeGraphic(FlxG.width, 70, 0xFF000000);
		bottomPanel.alpha = 0.8;
		add(bottomPanel);

		var scoreText:FlxText = new FlxText(50, bottomPanel.y + 20, FlxG.width, 'Current Mod: ' + Paths.currentMod, 28);
		scoreText.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		scoreText.borderSize = 2;

		add(scoreText);
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (controls.BACK)
		{
			FlxG.save.flush();
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new ModdingState());
		}

		if (controls.UI_UP_P)
			changeSelection(-1);
		if (controls.UI_DOWN_P)
			changeSelection(1);

		if (controls.ACCEPT)
		{
			switch (options[curSelected])
			{
				case "Add a new song":
					//wip
				case 'Character Editor':
					var theState:meta.modding.char_editor.CharacterEditor = new meta.modding.char_editor.CharacterEditor(false,true,false);
					theState.moddingMode = true;
					FlxG.switchState(theState);
				case 'Stage Editor':
					FlxG.switchState(new meta.modding.stage_editor.Better_StageEditor());
				case 'Week Editor':
					FlxG.sound.music.stop();
					FlxG.switchState(new meta.modding.week_editor.WeekEditor(''));	
				case 'Add Event Script':
					FlxG.switchState(new meta.modding.event_editor.EventScriptEditor());
			}
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.4);
		}
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = options.length - 1;
		if (curSelected >= options.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenu.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;
			item.selected = false;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.selected = true;
				item.alpha = 1;
			}
		}
	}
}
