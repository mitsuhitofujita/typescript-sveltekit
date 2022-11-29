import { error } from '@sveltejs/kit';
import { createClient } from 'microcms-js-sdk';
import type { MicroCMSListResponse } from 'microcms-js-sdk';

const client = createClient({
	serviceDomain: process.env.MICRO_CMS_SERVICE_DOMAIN,
	apiKey: process.env.MICRO_CMS_API_KEY
});
type Post = {
	id: string;
	createdAt: string;
	updatedAt: string;
	publishedAt: string;
	revisedAt: string;
	title: string;
	content: string;
};
/** @type {import('@sveltejs/kit').RequestHandler} */
export async function load() {
	const res = await client.get<MicroCMSListResponse<Post>>({
		endpoint: 'posts'
	});
	if (res) {
		return { ...res };
	}
	throw error(404, 'Not found');
}
