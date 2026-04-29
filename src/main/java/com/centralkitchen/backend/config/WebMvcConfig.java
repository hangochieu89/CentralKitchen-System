package com.centralkitchen.backend.config;

import org.springframework.boot.web.embedded.tomcat.TomcatServletWebServerFactory;
import org.springframework.boot.web.server.WebServerFactoryCustomizer;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.io.File;

@Configuration
public class WebMvcConfig implements WebServerFactoryCustomizer<TomcatServletWebServerFactory>, WebMvcConfigurer {
    private final ApiAuthInterceptor apiAuthInterceptor;

    public WebMvcConfig(ApiAuthInterceptor apiAuthInterceptor) {
        this.apiAuthInterceptor = apiAuthInterceptor;
    }

    @Override
    public void customize(TomcatServletWebServerFactory factory) {
        // Giup Tomcat nhan dien folder "frontend" lam Document Root (cho phep bien dich jsp)
        factory.setDocumentRoot(new File("frontend"));
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // Ánh xạ URL /css/** vào thư mục css nằm trong resources
        registry.addResourceHandler("/css/**")
                .addResourceLocations("classpath:/css/");
        // Ánh xạ URL /image/** vào thư mục image nằm trong resources
        registry.addResourceHandler("/image/**")
                .addResourceLocations("classpath:/image/");
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(apiAuthInterceptor)
                .addPathPatterns("/api/**");
    }
}
