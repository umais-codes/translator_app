allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    afterEvaluate {
        if (path == ":app") {
            return@afterEvaluate
        }
        val android = extensions.findByName("android") ?: return@afterEvaluate
        val appAndroid = project(":app").extensions.findByName("android") ?: return@afterEvaluate
        val sdkVersion = readCompileSdk(appAndroid) ?: return@afterEvaluate
        val setter = android.javaClass.methods.firstOrNull { method ->
            method.parameterCount == 1 &&
                method.parameterTypes[0] == Integer.TYPE &&
                method.name in setOf("compileSdkVersion", "setCompileSdk", "setCompileSdkVersion")
        } ?: return@afterEvaluate
        setter.invoke(android, sdkVersion)
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}

// Plugins such as app_settings pin an older compileSdk. Use the app SDK so
// Gradle does not try to download a platform that is not installed.
fun readCompileSdk(android: Any): Int? {
    val direct = android.javaClass.methods
        .firstOrNull { it.name == "getCompileSdk" && it.parameterCount == 0 }
        ?.invoke(android)
    if (direct is Int) {
        return direct
    }
    val named = android.javaClass.methods
        .firstOrNull { it.name == "getCompileSdkVersion" && it.parameterCount == 0 }
        ?.invoke(android)
        ?.toString()
        ?.removePrefix("android-")
        ?.toIntOrNull()
    return named
}
