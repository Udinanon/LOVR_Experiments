## WebGL vs OpenGL
WebGL and OpenGL are ever so sloghtly different, that the shader are not directly compatible
The fixes could be either manual, with a short description of the major differences, or automated
automatic fixing would be much more conveninet, but would have to either do simple matching and hope nothing breaks, or parse glsl correctly to switch between the two, which does not seem that easy

https://stackoverflow.com/questions/12307278/texture-vs-texture2d-in-glsl

Textur2D is a type in OpenGL, while it is a command in WebGL. 

### Correcting
I thought about using the preprocessor to manage the webgl shader code, but i think it's not going to work well at all
OpenGL does not allow recursive functions 


## Audio Sources
Another issue is the roles of `sound`, `floatSound` and `volume`
`volume` is just a weird combo of values relating to the intensity of the audio samples used, the code is mosty this
```js

s.processor = s.context.createScriptProcessor(1024, 1, 1); // buf is 1024 in time domain
// values are PCM [-1.0, 1.0]

s.processor.onaudioprocess = saveMaxSample; // i think a callback

 function saveMaxSample(e) {
    const buf = e.inputBuffer.getChannelData(0); // raw audio data 
    const len = buf.length; // 1024 
    var last = buf[0];
    var max = buf[0];
    var maxDif = 0;
    var sum = 0;
    for (var ii = 1; ii < len; ++ii) {
        var v = buf[ii];
        if (v > max) {
        v = max;
        }
        var dif = Math.abs(v - last);
        if (dif > maxDif) {
        maxDif = dif;
        }
        sum += v * v;
    }
    s.maxSample = max; // max audio volume value in section
    s.maxDif = maxDif; // biggest diff between a sample and the first sample (odd)
    s.sum = Math.sqrt(sum / len); // sum is all values squared, so this is sum_of_all(abs(values))/sqrt(len)
}

s.analyser.getByteFrequencyData(s.soundHistory.buffer);

// should we do this in a shader?
{
    const buf = s.soundHistory.buffer;
    const len = buf.length;
    var max = 0;
    for (let ii = 0; ii < len; ++ii) {
        const v = buf[ii];
        if (v > max) {
        max = v;
        }
    }

    s.volumeHistory.buffer[3] = max; // highest value of the fft over the current volume buffer
}
s.volumeHistory.buffer[0] = Math.abs(s.maxSample) * 255; // raised from [0.0, 1.0] to [0, 255]
s.volumeHistory.buffer[1] = s.sum * 255; // raised from [0.0, 1.0] to [0, 255]
s.volumeHistory.buffer[2] = s.maxDif * 127; // raised from [0.0, 1.0] to [0, 255] (dif can be [-2, 2]!)
```
This uses deprecated [createScriptProcessor()](https://developer.mozilla.org/en-US/docs/Web/API/BaseAudioContext/createScriptProcessor) commands to access audio data and then process it on a callback. docs for [getChannelData](https://developer.mozilla.org/en-US/docs/Web/API/AudioBuffer/getChannelData)


sound and floatSound are the FFT of the audio input, generated using 
[getFloatFrequencyData()](https://developer.mozilla.org/en-US/docs/Web/API/AnalyserNode/getFloatFrequencyData) and
[getByteFrequencyData()](https://developer.mozilla.org/en-US/docs/Web/API/AnalyserNode/getByteFrequencyData#specifications)
This means implementing some FFT code by ourselves or finding a library to do so, and pushing it as a texture
These functions do't have super defined parameters, such as number of frequency samples or what wave is used, so we have some wiggle room in implementation

They are all stored as Xx240 textures, with some specific sampling choices we will probably ignore for now
more relevant perhaps is the format
```js
s.volumeHistory = new HistoryTexture(gl, {
    width: 4, // oddly declared as 1 in the help section, why?
    length: s.numHistorySamples,
    format: gl.ALPHA,
});
```
gl.ALPHA is very undocumentaed, referenced only on a tutorial about [WebGL 1 Data Textures](https://webglfundamentals.org/webgl/lessons/webgl-data-textures.html) and in some deep [MSDN Docs](https://developer.mozilla.org/en-US/docs/Web/API/WebGLRenderingContext/texImage2D) as 1 byte 1 channel textures. Thuis seems consistent with our usage of the texture in tests. considering most code is from 2016, before the release of WebGL 2 in early 2017, it's likely the project is resting only on older standard. This is also supported by the usage of deprecated audio routing methods


The current result is promising but issues remain
more complex shaders don't respond as expected (see: Slash)
The sound texture seems to be still updated on the wrong axis, and the parameters need to e tweaked 
the float texture is empty, needs ait's own log weighted float FFT
the fft is still likley quite bad, slow for sure an likely imperfect

The results are still promising and could probably be branched into its own small repo for only this to be showcased, tested with others and shown around