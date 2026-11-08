Shader "Tecsup/S09/c"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _VignetteColor ("Vignette Color", Color) = (0, 0, 0, 1)
        _Intensity ("Intensity", Range(0, 1)) = 0.5
        _Power ("Power", Range(0.1, 8)) = 2.0
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
                float2 uv : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                half4 _VignetteColor;
                float _Intensity;
                float _Power;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float d = length(IN.uv - 0.5) * 2.0;

                float v = pow(saturate(d), _Power) * _Intensity;

                return lerp(_BaseColor, _VignetteColor, v);
            }
            ENDHLSL
        }
    }
}