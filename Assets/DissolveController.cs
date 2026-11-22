using UnityEngine;

public class DissolveController : MonoBehaviour
{
    public float speed = 0.6f;
    private Material mat;

    void Start()
    {
        mat = GetComponent<Renderer>().material;
    }

    void Update()
    {
        float value = Mathf.PingPong(Time.time * speed, 1f);
        mat.SetFloat("_DissolveAmount", value);
    }
}