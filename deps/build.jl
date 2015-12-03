using BinDeps
using Compat

@BinDeps.setup

opencv_version = "3.0.0"

opencv_core = library_dependency("libopencv_core")
opencv_highgui = library_dependency("libopencv_highgui")
opencv_imgcodecs = library_dependency("libopencv_imgcodecs")
opencv_imgproc = library_dependency("libopencv_imgproc")
opencv_videoio = library_dependency("libopencv_videoio")

opencv_libs = [
    opencv_core,
    opencv_highgui,
    opencv_imgcodecs,
    opencv_imgproc,
    opencv_videoio
    ]

### Source provider ###
github_root = "https://github.com/Itseez/opencv"
provides(Sources,
         URI("$(github_root)/archive/$(opencv_version).tar.gz"),
         opencv_libs,
         unpacked_dir="opencv-$(opencv_version)")

prefix = joinpath(BinDeps.depsdir(opencv_core), "usr")
srcdir = joinpath(BinDeps.depsdir(opencv_core), "src", "opencv-$(opencv_version)")

cmake_options = [
    "-DCMAKE_INSTALL_PREFIX=$prefix",
    "-DBUILD_SHARED_LIBS=ON",
    "-DBUILD_TIFF=ON",
    "-DWITH_CUDA=OFF",
    "-DENABLE_AVX=ON",
    "-DWITH_OPENGL=ON",
    "-DWITH_OPENCL=ON",
    "-DWITH_IPP=ON",
    "-DWITH_TBB=ON",
    "-DWITH_EIGEN=ON",
    "-DWITH_V4L=ON",
    "-DBUILD_TESTS=OFF",
    "-DBUILD_PERF_TESTS=OFF",
    "-DBUILD_EXAMPLES=OFF",
    "-DCMAKE_BUILD_TYPE=RELEASE",
    "-DBUILD_opencv_java=OFF",
    "-DBUILD_opencv_python=OFF",
    "-DBUILD_opencv_nonfree=OFF",
    "-DBUILD_DOCS=OFF",
]

### Build opencv from source ###
provides(SimpleBuild,
          (@build_steps begin
              GetSources(opencv_core)
              @build_steps begin
                  ChangeDirectory(srcdir)
                  `mkdir -p build`
                  @build_steps begin
                      ChangeDirectory(joinpath(srcdir, "build"))
                      `rm -f CMakeCache.txt`
                      `cmake $cmake_options ..`
                      `make -j4`
                      `make install`
                  end
                end
          end), opencv_libs, os = :Unix)

@BinDeps.install @compat Dict(
    :libopencv_core => :libopencv_core,
    :libopencv_highgui => :libopencv_highgui,
    :libopencv_imgcodecs => :libopencv_imgcodecs,
    :libopencv_imgproc => :libopencv_imgproc,
    :libopencv_videoio => :libopencv_videoio,
    )