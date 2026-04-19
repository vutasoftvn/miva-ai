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

subprojects {
    val proj = this
    fun applyNamespaceFix() {
        try {
            val android = proj.extensions.findByName("android") as? com.android.build.gradle.BaseExtension
            if (android != null) {
                var originalPackage: String? = null
                
                // 1. Try to extract original package from AndroidManifest.xml
                val manifestFile = proj.file("src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    val content = manifestFile.readText()
                    // Regex to find package="xxx"
                    val match = Regex("package=\"([^\"]*)\"").find(content)
                    if (match != null) {
                        originalPackage = match.groupValues[1]
                        
                        // 2. Remove 'package' attribute to satisfy AGP 8+
                        val newContent = content.replace(Regex("package=\"[^\"]*\""), "")
                        manifestFile.writeText(newContent)
                        println("[MIVA-FIX] Stripped package '$originalPackage' from ${proj.name} manifest")
                    }
                }

                // 3. Set namespace to original package (if found) or fallback
                if (android.namespace == null) {
                    android.namespace = originalPackage ?: "vn.mivacorp.ai.deps.${proj.name.replace("-", "_")}"
                    println("[MIVA-FIX] Set namespace to '${android.namespace}' for ${proj.name}")
                }
            }
        } catch (e: Exception) { }
    }

    if (proj.state.executed) {
        applyNamespaceFix()
    } else {
        proj.afterEvaluate { applyNamespaceFix() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
