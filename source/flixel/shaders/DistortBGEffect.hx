package flixel.shaders;

import grafex.states.playstate.PlayState;
import flixel.system.FlxAssets.FlxShader;
import flixel.Effect;

class DistortBGEffect extends Effect
{
	public var shader:DistortBGShader = new DistortBGShader();

	public var waveSpeed(default, set):Float = 0;
	public var waveFrequency(default, set):Float = 0;
	public var waveAmplitude(default, set):Float = 0;

	public function new(waveSpeed:Float, waveFrequency:Float, waveAmplitude:Float):Void
	{
		this.waveSpeed = waveSpeed;
		this.waveFrequency = waveFrequency;
		this.waveAmplitude = waveAmplitude;
		shader.uTime.value = [0];
		PlayState.instance.shaderUpdates.push(update);
	}

	public function update(elapsed:Float):Void
	{
		shader.uTime.value[0] += elapsed;
	}

	function set_waveSpeed(v:Float):Float
	{
		waveSpeed = v;
		shader.uSpeed.value = [waveSpeed];
		return v;
	}

	function set_waveFrequency(v:Float):Float
	{
		waveFrequency = v;
		shader.uFrequency.value = [waveFrequency];
		return v;
	}

	function set_waveAmplitude(v:Float):Float
	{
		waveAmplitude = v;
		shader.uWaveAmplitude.value = [waveAmplitude];
		return v;
	}
}

class DistortBGShader extends FlxShader
{
	@:glFragmentSource('
    #pragma header
    //uniform float tx, ty; // x,y waves phase

    //gives the character a glitchy, distorted outline
    uniform float uTime;
    
    /**
     * How fast the waves move over time
     */
    uniform float uSpeed;
    
    /**
     * Number of waves over time
     */
    uniform float uFrequency;
    
    /**
     * How much the pixels are going to stretch over the waves
     */
    uniform float uWaveAmplitude;

    vec2 sineWave(vec2 pt)
    {
        float x = 0.0;
        float y = 0.0;
        
        float offsetX = sin(pt.x * uFrequency + uTime * uSpeed) * (uWaveAmplitude / pt.x * pt.y);
        float offsetY = sin(pt.y * uFrequency - uTime * uSpeed) * (uWaveAmplitude);
        pt.x += offsetX; // * (pt.y - 1.0); // <- Uncomment to stop bottom part of the screen from moving
        pt.y += offsetY;

        return vec2(pt.x + x, pt.y + y);
    }

    vec4 makeBlack(vec4 pt)
    {
        return vec4(0, 0, 0, pt.w);
    }

    void main()
    {
        vec2 uv = sineWave(openfl_TextureCoordv);
        gl_FragColor = makeBlack(texture2D(bitmap, uv)) + texture2D(bitmap,openfl_TextureCoordv);
    }')
	public function new()
	{
		super();
	}
}