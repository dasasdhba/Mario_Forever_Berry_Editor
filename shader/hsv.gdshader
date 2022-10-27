// 类似 Photoshop 中的 HSV 调整效果
shader_type canvas_item;

uniform float hue: hint_range(-180.0,180.0) = 0.0;
uniform float saturation: hint_range(-1.0,1.0) = 0.0;
uniform float value: hint_range(-1.0,1.0) = 0.0;

float rgb2h(vec3 col, float maxf, float minf) {
    if (maxf == minf) {
        return 0.0;
    }

    float delta = maxf - minf;

    if (maxf == col.r) {
        if (col.g >= col.b) {
            return 60.0*(col.g-col.b)/delta;
        }
        else {
            return 60.0*(col.g-col.b)/delta + 360.0;
        }
    }

    if (maxf == col.g) {
        return 60.0*(col.b-col.r)/delta + 120.0;
    }

    return 60.0*(col.r-col.g)/delta + 240.0;
}

vec3 hsv2rgb(float h, float s, float v) {
    int i = int(h/60.0) % 6;
    float f = h/60.0 - float(i);
    float p = v*(1.0-s);
    float q = v*(1.0-f*s);
    float t = v*(1.0-(1.0-f)*s);

    switch(i) {
        case 0: return vec3(v,t,p);
        case 1: return vec3(q,v,p);
        case 2: return vec3(p,v,t);
        case 3: return vec3(p,q,v);
        case 4: return vec3(t,p,v);
        case 5: return vec3(v,p,q);
    }
}

float wrapf(float r, float minf, float maxf) {
    float delta = maxf - minf;
    while (r >= maxf) {
        r -= delta;
    }
    while (r < minf) {
        r += delta;
    }
    return r;
}

vec3 hsv(vec3 col) {
    float maxf = max(col.r,max(col.g,col.b));
    float minf = min(col.r,min(col.g,col.b));
    float h = rgb2h(col,maxf,minf);
    float sat;
    float light = (maxf+minf)/2.0;
    if (maxf == 0.0) {
        sat = 0.0;
    }
    else {
        sat = 1.0 - minf/maxf;
    }

    h += hue;
    h = wrapf(h,0.0,360.0);

    if (maxf != minf && saturation != 0.0) {
        float satl, alpha;
        if (saturation > 0.0) {
            if (light == 0.0 || light == 1.0) {
                satl = 0.0;
            }
            else if (light < 0.5) {
                satl = (maxf-minf)/(2.0*light);
            }
            else {
                satl = (maxf-minf)/(2.0*(1.0-light));
            }

            if (satl+saturation >= 1.0) {
                alpha = satl;
            }
            else {
                alpha = 1.0-saturation;
            }
            alpha = 1.0/alpha - 1.0;

            maxf += alpha*(maxf - light);
            sat = 1.0-(minf + alpha*(minf-light))/maxf;
        }
        else {
            alpha = 1.0+saturation;
            maxf = light + alpha*(maxf - light);
            sat = 1.0-(light + alpha*(minf-light))/maxf;
        }
    }

    maxf += value;
    maxf = clamp(maxf,0.0,1.0);

    return hsv2rgb(h,sat,maxf);

}

void fragment() {
	vec4 col = texture(TEXTURE, UV);

    if (col.a != 0.0) {
        col.rgb = hsv(col.rgb);
    }
	
	COLOR = col;
}
