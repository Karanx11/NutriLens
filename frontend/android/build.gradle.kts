allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// flutter_secure_storage 11 declares compileSdk = 37, but AGP 8.11 cannot
// resolve the minor-versioned "android-37.0" platform (it looks up the hash
// "android-37"). The plugin only uses APIs up to 30, so compile any library
// that asks for a newer SDK against the installed SDK 36 instead.
subprojects {
    val sub = this
    // React only to library modules (this skips ":app"). Use AGP's variant
    // API: finalizeDsl runs after the module's build script has set compileSdk
    // but before AGP reads and locks it — afterEvaluate is already too late.
    sub.plugins.withId("com.android.library") {
        sub.extensions
            .findByType<com.android.build.api.variant.LibraryAndroidComponentsExtension>()
            ?.finalizeDsl { android ->
                val requested = android.compileSdk
                if (requested != null && requested > 36) {
                    android.compileSdk = 36
                }
            }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
