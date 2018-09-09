// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/WorldSpaceNormals"
{
	Properties{
		_Color("Color", color) = (1,1,1,0)
	}
	// no Properties block this time!
	SubShader
	{
		Pass
		{
			CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
			// include file that contains UnityObjectToWorldNormal helper function
	#include "UnityCG.cginc"

			struct v2f {
				// we'll output world space normal as one of regular ("texcoord") interpolators
				half3 worldNormal : TEXCOORD0;
				float4 pos : SV_POSITION;
			};

			// vertex shader: takes object space normal as input too
			v2f vert(float4 vertex : POSITION, float3 normal : NORMAL)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(vertex);
				// UnityCG.cginc file contains function to transform
				// normal from object to world space, use that
				o.worldNormal = UnityObjectToWorldNormal(normal);
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 c = 0;
			// normal is a 3D vector with xyz components; in -1..1
			// range. To display it as color, bring the range into 0..1
			// and put into red, green, blue components
				c.rgb = i.worldNormal*0.5 + 0.5;
				if (i.pos.y > 0)
				{
					c.r = 1;
				}
				return c;
			}
			ENDCG
		}
	//	Pass
	//	{
	//		CGPROGRAM
	//#pragma vertex vert
	//#pragma fragment frag

	//		// vertex shader
	//		// this time instead of using "appdata" struct, just spell inputs manually,
	//		// and instead of returning v2f struct, also just return a single output
	//		// float4 clip position
	//		float4 vert(float4 vertex : POSITION) : SV_POSITION
	//		{
	//			return UnityObjectToClipPos(vertex);
	//		}

	//		// color from the material
	//		fixed4 _Color;

	//		// pixel shader, no inputs needed
	//		fixed4 frag() : SV_Target
	//		{
	//			return _Color; // just return it
	//		}
	//		ENDCG
	//	}
	}
}