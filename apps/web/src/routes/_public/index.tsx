import { getPageSeo } from "@/features/seo/api";
import { seoHead, pageSeoDefaults } from "@/features/seo/metadata";
import { Home } from "@/features/landing/home";
import { brandConfig } from "@config/brand";
import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/_public/")({
  loader: () => getPageSeo({ data: "home" }),
  staleTime: 0,
  head: ({ loaderData }) => seoHead(loaderData ?? pageSeoDefaults(brandConfig, "home"), "/", brandConfig),
  component: HomeComponent,
});

function HomeComponent() {
  return (
    <>
      <Home />
    </>
  );
}
