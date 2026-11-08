Shader "Tecsup/S09/j"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        _TexB ("Texture B", 2D) = "white" {}
        _Blend ("Blend Factor", Range(0, 1)) = 0.0
    }

    SubShader
    {
        Tags { "RenderType" = "Opaque" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            HLSLPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float2 uvA : TEXCOORD0;
                float2 uvB : TEXCOORD1;
            };

            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);

            TEXTURE2D(_TexB);
            SAMPLER(sampler_TexB);

            CBUFFER_START(UnityPerMaterial)
                float4 _MainTex_ST;
                float4 _TexB_ST;
                float _Blend;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                
                OUT.uvA = TRANSFORM_TEX(IN.uv, _MainTex);
                OUT.uvB = TRANSFORM_TEX(IN.uv, _TexB);
                
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                half4 texA = SAMPLE_TEXTURE2D(_MainTex, sampler_MainTex, IN.uvA);
                half4 texB = SAMPLE_TEXTURE2D(_TexB, sampler_TexB, IN.uvB);

                float3 finalColor = lerp(texA.rgb, texB.rgb, _Blend);
                float finalAlpha = lerp(texA.a, texB.a, _Blend);

                return half4(finalColor, finalAlpha);
            }
            ENDHLSL
        }
    }
}