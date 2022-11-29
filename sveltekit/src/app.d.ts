// See https://kit.svelte.dev/docs/types#app
// for information about these interfaces
// and what to do when importing types
declare namespace App {
	// interface Error {}
	// interface Locals {}
	// interface PageData {}
	// interface Platform {}
}
declare namespace NodeJS {
	interface ProcessEnv {
		readonly MICRO_CMS_SERVICE_DOMAIN: string;
		readonly MICRO_CMS_API_KEY: string;
	}
}
