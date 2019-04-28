Shader "Quest/Toon"
{
	Properties
	{
		_MainTex ("Main Texture", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
        
        _RimColor("Rim Color", Color) = (1,1,1,1)
        _RimRange("Rim Range", Range(0,1)) = 0.7
        _RimBrightness("Rim Brightness", Range(0,5)) = 2
	}
	SubShader
	{
		Pass
		{
            Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "AutoLight.cginc"
			#include "Lighting.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float4 normal : NORMAL;
				fixed2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				fixed2 uv : TEXCOORD0;
				fixed3 worldNormal : TEXCOORD1;
                fixed3 viewDir : TEXCOORD2;
			};

			sampler2D _MainTex;
			fixed4 _MainTex_ST;
			fixed4 _Color;
            fixed4 _RimColor;
            fixed _RimRange;
            fixed _RimBrightness;
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = normalize(_WorldSpaceCameraPos - mul(unity_ObjectToWorld, v.vertex)).xyz;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv) * _Color;

				fixed4 lightCol = _LightColor0;
				fixed4 lightDir = _WorldSpaceLightPos0;

				fixed3 indirectLight = ShadeSH9(fixed4(0,0,0,1));

				fixed ndl = DotClamped(i.worldNormal, _WorldSpaceLightPos0);
                fixed vdn = (abs(dot(i.viewDir, i.worldNormal)));
                fixed shadow = ceil(ndl);

                fixed rimIntensity = saturate((1-vdn) * pow(ndl, 0.15));
                rimIntensity = smoothstep(_RimRange, _RimRange, rimIntensity);
                fixed4 rim = rimIntensity * _RimColor * _RimBrightness;

				fixed3 light = shadow * lightCol.rgb;
				light += indirectLight;
                light += rim.rgb;

				return col * light.xyzz;
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
}
