import MapboxCoreMaps
@_implementationOnly import MapboxCoreMaps_Private

final class MockMapClient: MapClient, MBMMetalViewProvider {
    func scheduleRepaint() {
    }

    let getMetalViewStub = Stub<MTLDevice?, MTKView?>(defaultReturnValue: nil)
    func getMetalView(for metalDevice: MTLDevice?) -> MTKView? {
        getMetalViewStub.call(with: metalDevice)
    }
}
