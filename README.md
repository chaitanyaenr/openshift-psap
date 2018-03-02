# openshift-psap
OpenShift Performance-Sensitive Application Platform Artifacts

### Ansible Roles

#### tuned-setup
This role will demonstrate use of the tuned tuning profile delivery mechanism to partition your node into two sections; housekeeping and isolated cores.  These cores are de-jittered (as much as possible) from kernel activity and will not run userspace threads unless those threads have their affinity explicitly defined.

The ansible inventory includes several variables use to configure tuned:

* ```isolated_cores``` the list of cores to be de-jittered.
* ```nr_hugepages``` the number of 2Mi hugepages to be allocated.

#### tandt-setup
This role will demonstrate use of Taints and Tolerations to carve out a "node pool" called fastnode.  Pods without matching tolerations will not be scheduled to this isolated pool.

#### gpu-pod
This role will create a new pod that leverages Taints and Tolerations to run on the fastnode pool.  It consumes a GPU.  The pod sleeps indefinitely.  To test your GPU pod:
Also included is a basic Dockerfile that is based on the NVIDIA CUDA 9.1 CentOS7 image and includes the deviceQuery binary used below.


Run the deviceQuery command.  This demonstrates that the process in the pod has access to the GPU hardware.  If it did not, the Result at the bottom would indicate FAIL.
```
# oc rsh gpu-pod /usr/local/cuda-9.1/samples/1_Utilities/deviceQuery/deviceQuery
/usr/local/cuda-9.1/samples/1_Utilities/deviceQuery/deviceQuery Starting...

 CUDA Device Query (Runtime API) version (CUDART static linking)

Detected 1 CUDA Capable device(s)

Device 0: "Tesla M60"
  CUDA Driver Version / Runtime Version          9.1 / 9.1
  CUDA Capability Major/Minor version number:    5.2
  Total amount of global memory:                 7619 MBytes (7988903936 bytes)
  (16) Multiprocessors, (128) CUDA Cores/MP:     2048 CUDA Cores
  GPU Max Clock rate:                            1178 MHz (1.18 GHz)
  Memory Clock rate:                             2505 Mhz
  Memory Bus Width:                              256-bit
  L2 Cache Size:                                 2097152 bytes
  Maximum Texture Dimension Size (x,y,z)         1D=(65536), 2D=(65536, 65536), 3D=(4096, 4096, 4096)
  Maximum Layered 1D Texture Size, (num) layers  1D=(16384), 2048 layers
  Maximum Layered 2D Texture Size, (num) layers  2D=(16384, 16384), 2048 layers
  Total amount of constant memory:               65536 bytes
  Total amount of shared memory per block:       49152 bytes
  Total number of registers available per block: 65536
  Warp size:                                     32
  Maximum number of threads per multiprocessor:  2048
  Maximum number of threads per block:           1024
  Max dimension size of a thread block (x,y,z): (1024, 1024, 64)
  Max dimension size of a grid size    (x,y,z): (2147483647, 65535, 65535)
  Maximum memory pitch:                          2147483647 bytes
  Texture alignment:                             512 bytes
  Concurrent copy and kernel execution:          Yes with 2 copy engine(s)
  Run time limit on kernels:                     No
  Integrated GPU sharing Host Memory:            No
  Support host page-locked memory mapping:       Yes
  Alignment requirement for Surfaces:            Yes
  Device has ECC support:                        Enabled
  Device supports Unified Addressing (UVA):      Yes
  Supports Cooperative Kernel Launch:            No
  Supports MultiDevice Co-op Kernel Launch:      No
  Device PCI Domain ID / Bus ID / location ID:   0 / 0 / 30
  Compute Mode:
     < Default (multiple host threads can use ::cudaSetDevice() with device simultaneously) >

deviceQuery, CUDA Driver = CUDART, CUDA Driver Version = 9.1, CUDA Runtime Version = 9.1, NumDevs = 1
Result = PASS
```

### Node-feature-discovery
We can use this feature to add labels to the nodes to advertise hardware features.
 
#### Run 
```
$ cd node-feature-discovery
$ ./node_feature_discovery.sh
```
This script will create pods equal to the number of nodes using a privileged serviceaccount after creating a role and binding the default user to view the pods in the node-feature-discovery namespace. The nodes will get labeled with the hardware features available on the node. Following are the labels which got added to the nodes after a sample run:

```
$ oc get nodes -o json | jq .items[].metadata.labels 

{
  "beta.kubernetes.io/arch": "amd64",
  "beta.kubernetes.io/instance-type": "t2.medium",
  "beta.kubernetes.io/os": "linux",
  "failure-domain.beta.kubernetes.io/region": "us-west-2",
  "failure-domain.beta.kubernetes.io/zone": "us-west-2b",
  "kubernetes.io/hostname": "ip-172-31-1-23.us-west-2.compute.internal",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-AESNI": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-AVX": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-AVX2": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-BMI1": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-BMI2": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-CLMUL": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-CMOV": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-CX16": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-ERMS": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-F16C": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-FMA3": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-LZCNT": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-MMX": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-MMXEXT": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-NX": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-POPCNT": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-RDRAND": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-RDTSCP": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-SSE": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-SSE2": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-SSE3": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-SSE4.1": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-SSE4.2": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-SSSE3": "true",
  "node.alpha.kubernetes-incubator.io/node-feature-discovery.version": "v0.1.0-dirty",
  "region": "primary",
  "zone": "default"
}
{
  "beta.kubernetes.io/arch": "amd64",
  "beta.kubernetes.io/instance-type": "t2.medium",
  "beta.kubernetes.io/os": "linux",
  "failure-domain.beta.kubernetes.io/region": "us-west-2",
  "failure-domain.beta.kubernetes.io/zone": "us-west-2b",
  "kubernetes.io/hostname": "ip-172-31-9-21.us-west-2.compute.internal",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-AESNI": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-AVX": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-AVX2": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-BMI1": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-BMI2": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-CLMUL": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-CMOV": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-CX16": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-ERMS": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-F16C": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-FMA3": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-LZCNT": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-MMX": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-MMXEXT": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-NX": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-POPCNT": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-RDRAND": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-RDTSCP": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-SSE": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-SSE2": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-SSE3": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-SSE4.1": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-SSE4.2": "true",
  "node.alpha.kubernetes-incubator.io/nfd-cpuid-SSSE3": "true",
  "node.alpha.kubernetes-incubator.io/node-feature-discovery.version": "v0.1.0-dirty",
  "node_role": "node",
  "pbench_role": "agent",
  "region": "primary",
  "zone": "default"
}

```
