Shader "Custom/BuildingShader"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _SpecularMap ("Specular / Roughness Map", 2D) = "white" {}
        _HeightMap ("Height Map", 2D) = "gray" {}
        _AOMap ("Ambient Occlusion Map", 2D) = "white" {}
        _EmissiveMap ("Emissive Map", 2D) = "black" {}
        _EmissionColor ("Emission Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            sampler2D _SpecularMap;
            sampler2D _HeightMap;
            sampler2D _AOMap;
            sampler2D _EmissiveMap;
            float4 _EmissionColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Muestreo de texturas principales
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed4 ao = tex2D(_AOMap, i.uv);
                fixed4 emissive = tex2D(_EmissiveMap, i.uv) * _EmissionColor;

                // Aplicar oclusión ambiental a la textura base
                col.rgb *= ao.rgb;

                // Sumar la emisión para que las ventanas brillen
                col.rgb += emissive.rgb;

                return col;
            }
            ENDCG
        }
    }
}