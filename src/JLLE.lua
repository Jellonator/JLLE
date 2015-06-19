JL = {};
JLREQ = {
	anim = true,
	line = true,
	xml = true,
	box = true,
	bitset = true,
	grid = true,
	graphics = true,
}
if (JLLE) then JLLE(JLREQ) end
--uppercase = tables
JL.World = {};
JL.Entity = {};
JL.Screen = {};
JL.Math = {};
JL.Graphics = {};
JL.Mask = {};
JL.Arm = {};
JL.XML = {};
JL.Util = {};
JL.Table = {};
JL.path = (...):match("(.-)[^%.]+$");       --the path of the JLLE library
--requiring ALL the things
--Core features
require(JL.path.."Entity");					--handles entities
require(JL.path.."World");					--template world
--Utilities, required
require(JL.path.."Utils.File");
require(JL.path.."Utils.Math");				--math stuff
require(JL.path.."Utils.Table");			--table stuff
--system, required
require(JL.path.."Sys.Init");				--called once on start
require(JL.path.."Sys.Update");				--called every frame
require(JL.path.."Sys.Render");				--renders the screen
--utilities, not necessary
if(JLREQ.xml)then 		
	require(JL.path.."Utils.XML");
	require(JL.path.."Utils.TMX");
end		--XML parser
require(JL.path.."Mask")
if(JLREQ.grid)then 		require(JL.path.."Masks.Grid");end		--Grid system
if(JLREQ.box)then 		require(JL.path.."Masks.Box");end		--Box system
if(JLREQ.line)then 		require(JL.path.."Masks.Line");end		--Line system
--graphics
if (JLREQ.graphics) then
	require(JL.path.."Graphics") 				--template graphic
	require(JL.path.."Graphics.Image");			--image
	require(JL.path.."Graphics.Spritemap");		--animated image
	require(JL.path.."Graphics.Camera");		--camera
	require(JL.path.."Graphics.Tilemap");		--tiles
	require(JL.path.."Graphics.Tileset");		--tileset
	require(JL.path.."Graphics.Canvas");		--canvas
end
--animation/armature
if JLREQ.anim then
	require(JL.path.."Arm");				--armature
	--utilities, animation
	require(JL.path.."Utils.Anim");			--Arm animation
	require(JL.path.."Utils.Anim.Frame");	--Arm animation frame
	require(JL.path.."Utils.Anim.Fanim");	--Arm animation frame
	require(JL.path.."Utils.Ease");			--Easing functions
end
--no idea what this is
require(JL.path.."Utils.Basic");
