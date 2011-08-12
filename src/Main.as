package 
{
	import com.bit101.components.ComboBox;
	import com.bit101.components.InputText;
	import com.bit101.components.Label;
	import com.bit101.utils.MinimalConfigurator;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import math.Random;
	import net.vis4.geom.CatmullRomSpline;
	import net.vis4.streamgraph.BasicLateOnsetSort;
	import net.vis4.streamgraph.BelievableDataSource;
	import net.vis4.streamgraph.ColorPicker;
	import net.vis4.streamgraph.DataSource;
	import net.vis4.streamgraph.InverseVolatilitySort;
	import net.vis4.streamgraph.LastFMColorPicker;
	import net.vis4.streamgraph.LateOnsetDataSource;
	import net.vis4.streamgraph.LateOnsetSort;
	import net.vis4.streamgraph.LayerLayout;
	import net.vis4.streamgraph.LayerSort;
	import net.vis4.streamgraph.MinimizedWiggleLayout;
	import net.vis4.streamgraph.NoLayerSort;
	import net.vis4.streamgraph.RandomColorPicker;
	import net.vis4.streamgraph.StackLayout;
	import net.vis4.streamgraph.StreamgraphGenerator;
	import net.vis4.streamgraph.StreamLayout;
	import net.vis4.streamgraph.ThemeRiverLayout;
	import net.vis4.streamgraph.VolatilitySort;
	
	/**
	 * Demonstration of as3streamgraph library
	 * 
	 * @author Gregor Aisch
	 */
	public class Main extends Sprite 
	{
		protected var ui:MinimalConfigurator;
		protected var credits:Label;
		
		public function Main():void 
		{
			stage.scaleMode = 'noScale';
			stage.align = 'TL';
			
			ui = new MinimalConfigurator(this);
			ui.addEventListener(Event.COMPLETE, onUIComplete);
			ui.loadXML('ui.xml');
			
			credits = new Label(this, 10, stage.stageHeight - 60, 'STREAMGRAPH DEMO\nOriginal implementation by Lee Byron and Martin Wattenberg.\nSource: https://github.com/gka/as3streamgraph-demo');
			
			stage.addEventListener(Event.RESIZE, onResize);
		}
		
		protected function onResize(e:Event):void 
		{
			credits.y = stage.stageHeight - 60;
			renderStreamgraph();
		}
		
		protected function onUIComplete(e:Event):void 
		{
			var clay:ComboBox = ComboBox(ui.getCompById('layout'));
			clay.items = ['Stream', 'ThemeRiver', 'Minimized Wiggle', 'Stacked']; 
			clay.selectedIndex = 0;
			clay.addEventListener(Event.SELECT, renderStreamgraph);
			
			var cord:ComboBox = ComboBox(ui.getCompById('ordering'));
			cord.items = ['Late Onset', 'Basic Late Onset', 'Volatility', 'Inverse Volatility', 'No Sorting']; 
			cord.selectedIndex = 0;
			cord.addEventListener(Event.SELECT, renderStreamgraph);
			
			var ccol:ComboBox = ComboBox(ui.getCompById('coloring'));
			ccol.items = ['LastFM/NYT', 'LastFM', 'Random']; 
			ccol.selectedIndex = 0;
			ccol.addEventListener(Event.SELECT, renderStreamgraph);
			
			var cdata:ComboBox = ComboBox(ui.getCompById('data'));
			cdata.items = ['Late Onset', 'Believable']; 
			cdata.selectedIndex = 0;
			cdata.addEventListener(Event.SELECT, renderStreamgraph);
			
			InputText(ui.getCompById('seed')).addEventListener(Event.CHANGE, renderStreamgraph);
			InputText(ui.getCompById('layerSize')).addEventListener(Event.CHANGE, renderStreamgraph);
			InputText(ui.getCompById('numLayers')).addEventListener(Event.CHANGE, renderStreamgraph);
			
			ui.getCompById('randomize').addEventListener(MouseEvent.CLICK, randomize);
			
			renderStreamgraph();	
		}
		
		protected function randomize(e:MouseEvent):void 
		{
			Random.randomSeed();
			InputText(ui.getCompById('seed')).text = String(Random.integer(0, 10000));
			renderStreamgraph();
		}
		
		protected function get seed():int 
		{
			return int(InputText(ui.getCompById('seed')).text);
		}
		
		protected function get layerSize():int 
		{
			return int(InputText(ui.getCompById('layerSize')).text);
		}
		
		protected function get numLayers():int 
		{
			return int(InputText(ui.getCompById('numLayers')).text);
		}
		
		protected function get layout():LayerLayout
		{
			switch (ComboBox(ui.getCompById('layout')).selectedIndex) {
				case 0: return new StreamLayout();
				case 1: return new ThemeRiverLayout();
				case 2: return new MinimizedWiggleLayout();
				case 3: return new StackLayout();
			}
			throw new Error('unknown layout');
		}
		
		protected function get data():DataSource
		{
			switch (ComboBox(ui.getCompById('data')).selectedIndex) {
				case 0: return new LateOnsetDataSource(seed);
				case 1: return new BelievableDataSource(seed);
			}
			throw new Error('unknown data source');
		}
		
		protected function get ordering():LayerSort
		{
			switch (ComboBox(ui.getCompById('ordering')).selectedIndex) {
				case 0: return new LateOnsetSort();
				case 1: return new BasicLateOnsetSort();
				case 2: return new VolatilitySort();
				case 3: return new InverseVolatilitySort();
				case 4: return new NoLayerSort();
			}
			throw new Error('unknown ordering');
		}		
		
		protected function get coloring():ColorPicker
		{
			switch (ComboBox(ui.getCompById('coloring')).selectedIndex) {
				case 0: return new LastFMColorPicker('assets/layers-nyt.jpg');
				case 1: return new LastFMColorPicker('assets/layers.jpg');
				case 2: return new RandomColorPicker(seed);
			}
			throw new Error('unknown coloring');
		}
		
		protected function renderStreamgraph(e:Event = null):void 
		{
			graphics.clear();
			
			var viewport:Rectangle = new Rectangle(
				0, (stage.stageHeight - stage.stageWidth * .35) * .5, 
				stage.stageWidth, stage.stageWidth * .35
			);
			
			CatmullRomSpline.segments = (stage.stageWidth / layerSize) / 2;
			
			new StreamgraphGenerator( {
				container: this, 
				viewport: viewport,
				layout: layout,
				coloring: coloring,
				ordering: ordering,
				data: data,
				numLayers: numLayers,
				layerSize: layerSize
				//coloring: new RandomColorPicker(2, 0, 60)
			});
		}
		
	}
	
}