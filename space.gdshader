    shader_type canvas_item; //set type of object it applies to

    uniform vec2 direction; //x and y direction
    uniform float speed; //speed value
uniform vec4 c1 : source_color;
uniform vec4 c2 : source_color;
uniform vec4 c3 : source_color;


    void vertex(){ //applies to every single vertex
    }

    void fragment(){ //applies to every single pixel
        vec2 move = direction * TIME * speed; //create offset
        vec4 c = texture(TEXTURE, UV + move); //set colour
		if (c.x < 0.433){
			COLOR = c1;
		} else if (c.x < 0.666){
			COLOR = c2;
		} else{
			COLOR = c3;
		}
    }