$NetBSD: patch-compiler_rustc__llvm_build.rs,v 1.8 2022/08/30 19:22:17 he Exp $

Fix build on NetBSD HEAD-llvm. XXX there is probably a better way to do this.

--- compiler/rustc_llvm/build.rs.orig	2021-11-01 07:17:29.000000000 +0000
+++ compiler/rustc_llvm/build.rs
@@ -331,7 +331,13 @@ fn main() {
         "c++"
     } else if target.contains("netbsd") && llvm_static_stdcpp.is_some() {
         // NetBSD uses a separate library when relocation is required
-        "stdc++_pic"
+        if env::var_os("PKGSRC_HAVE_LIBCPP").is_some() {
+            "c++_pic"
+        } else {
+            "stdc++_pic"
+        }
+    } else if env::var_os("PKGSRC_HAVE_LIBCPP").is_some() {
+        "c++"
     } else if llvm_use_libcxx.is_some() {
         "c++"
     } else {
