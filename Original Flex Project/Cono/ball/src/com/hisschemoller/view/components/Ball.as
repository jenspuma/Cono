package com.hisschemoller.view.components 
{
	import com.bit101.components.Component;
	import com.hisschemoller.model.vo.AudioStreamInfoVO;
	import com.hisschemoller.model.vo.BallVO;

	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * @author wouter.hisschemoller
	 * (c) Lost Boys Feb 9, 2010
	 */
	public class Ball extends Component 
	{
		public static const BOUNCE : String = "bounce";
		private var _history : Vector.<BallVO> = new Vector.<BallVO>();
		private var _radius : int = 1;
		private var _gravity : Number = 0.5;
		private var _floorY : Number;
		private var _x : Number;
		private var _y : Number = 0;
		private var _vx : Number = 0;
		private var _vy : Number = 0;
		private var _hitAlpha : Number = 0;
		private var _midiChannel : int = -1;
		private var _isDragging : Boolean;
		
		public function Ball(parent : DisplayObjectContainer = null, xpos : Number = 0, ypos : Number = 0)
		{
			super(parent, xpos, ypos);
		}
		
		/**
		 * 
		 */
		public function setProperties(x: Number, y : Number, radius : Number, floorY : Number, midiChannel : int) : void
		{
			_x = x;
			_y = y;
			_radius = radius;
			_floorY = floorY;
			_midiChannel = midiChannel;
			
			_history.splice(0, 0, new BallVO(_x, _y, 0, 0, false));
			_history.splice(0, 0, new BallVO(_x, _y, 0, 0, false));
		}

		/**
		 * Calculate the new ball position.
		 */
		public function enterBuffer() : void
		{
			var hit : Boolean;
			
			if(_isDragging)
			{
				_vy = 0;
			}
			else
			{
				_vy += _gravity;
				_y += _vy;
				
				/** If the ball hits the floor. */
				if(_y > _floorY - _radius)
				{
					var distance : Number = _vy;
					var overlap : Number = _y + _radius - _floorY;
					_hitAlpha = (distance - overlap) / distance;
					
					_y = _floorY - _radius - overlap;
					_vy *= -1;
					hit = true;
					
					dispatchEvent(new Event(Ball.BOUNCE));
				}
			}
			
			/** Store as data for later use. */
			_history.splice(0, 0, new BallVO(_x, _y, _vx, _vy, hit));
			
			/** Keep maximum 100 history items so the maximum latency is buffer * 100. */
			if(_history.length > 100)
			{
				var n : int = _history.length;
				while(--n > 99)
				{
					_history.pop();
				}
			}
		}

		/**
		 * Create a new ball position.
		 */
public function enterFrame(infoVO : AudioStreamInfoVO) : void
{
	graphics.clear();
	graphics.lineStyle(2, 0xFFFFFF);
	graphics.beginFill(0xBBBBBB, 0.1);
	
	if(_isDragging)
	{
		graphics.drawCircle(_x, _y, _radius);
	}
	else
	{
		var time : Number = new Date().getTime() - infoVO.latencyInMS;
		
		var i : int = -1;
		var n : int = _history.length;
		while(++i < n)
		{
			/** Get the data from immediately before and after 'time'. */
			if(_history[i].time < time && i > 0)
			{
				var before : BallVO = _history[i];
				var after : BallVO = _history[i - 1];
				var alpha : Number = (time - before.time) / (after.time - before.time);
				
				/** If a bounce on the floor happened between before and after. */
				if(before.vy > 0 && after.vy < 0)
				{
					/** Linear interpolation to correct the vertical position. */
					var maxY : Number = _floorY - _radius;
					var partBeforeBounce : Number = maxY - before.y;
					var partAfterBounce : Number = maxY - after.y;
					var bounceAlpha : Number = partBeforeBounce / (partBeforeBounce + partAfterBounce);
					
					if(alpha < bounceAlpha)
					{
						var y : Number = before.y + (before.vy * bounceAlpha);
					}
					else
					{
						y = after.y + (before.vy * (1 - bounceAlpha));
					}
				}
				else
				{
					/** Regular linear interpolation for a ball in mid flight. */
					y = before.y + (alpha * (after.y - before.y));
				}
				
				if(before.hit) graphics.beginFill(0xFFFFFF);
				graphics.drawCircle(_x, y, _radius);
				
				break;
			}
		}
	}
}

		/**
		 * 
		 */
		public function set gravity(value : Number) : void
		{
			_gravity = value;
		}
		
		/**
		 * 
		 */
		public function get hitAlpha() : Number
		{
			return _hitAlpha;
		}
		
		/**
		 * 
		 */
		public function get midiChannel() : int
		{
			return _midiChannel;
		}
		
		/**
		 * 
		 */
		override protected function init() : void
		{
			super.init();
			
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		/**
		 * 
		 */
		private function mouseDownHandler(event : MouseEvent) : void
		{
			_isDragging = true;
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.addEventListener(Event.MOUSE_LEAVE, mouseUpHandler);
		}
		
		/**
		 * 
		 */
		private function mouseMoveHandler(event : MouseEvent) : void
		{
			if(_isDragging)
			{
				_x = mouseX;
				_y = Math.min(mouseY, _floorY - _radius);
			}
		}
		
		/**
		 * 
		 */
		private function mouseUpHandler(event : Event) : void
		{
			_isDragging = false;
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.removeEventListener(Event.MOUSE_LEAVE, mouseUpHandler);
		}
	}
}
