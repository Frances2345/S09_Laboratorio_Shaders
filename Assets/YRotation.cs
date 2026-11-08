using UnityEngine;

public class YRotation : MonoBehaviour
{
    [Header("Velocidad por Segundo")]
    [SerializeField] private float rotationSpeed = 50f;

    void Update()
    {
        transform.Rotate(Vector3.up * rotationSpeed * Time.deltaTime);
    }
}