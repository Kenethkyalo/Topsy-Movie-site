buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.android.tools.build:gradle:8.1.1") // ✅ Fixed syntax
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.buildDir = file("../build") // ✅ Fixed type issue

subprojects {
    project.buildDir = file("${rootProject.buildDir}/${project.name}") // ✅ Fixed type issue
}

tasks.register<Delete>("clean") { // ✅ Corrected task syntax
    delete(rootProject.buildDir)
}
