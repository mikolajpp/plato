const path = require("path");
const webpack = require("webpack");
const merge = require("webpack-merge");
const history = require('koa-connect-history-api-fallback');
const convert = require('koa-connect');
const proxy = require('http-proxy-middleware');

const CopyWebpackPlugin = require("copy-webpack-plugin");
const HTMLWebpackPlugin = require("html-webpack-plugin");
const CleanWebpackPlugin = require("clean-webpack-plugin");

const express = require('express');
var app = express();

// to extract the css as a separate file
const MiniCssExtractPlugin = require("mini-css-extract-plugin");

var MODE = process.env.npm_lifecycle_event === "prod" ? "production" : "development";
var filename = MODE == "production" ? "[name]-[hash].js" : "index.js";

var common = {
    mode: MODE,
    entry: "./src/index.js",
    output: {
        path: path.join(__dirname, "dist"),
        // webpack -p automatically adds hash when building for production
        filename: filename
    },
    plugins: [
        new HTMLWebpackPlugin({
            // Use this template to get basic responsive meta tags
            template: "src/index.html",
            // inject details of output file at end of body
            inject: "body"
        })
    ],
    resolve: {
        modules: [path.join(__dirname, "src"), 
		  path.join(__dirname, "src/assets"),
		"node_modules",
	path.join(__dirname, "src/Ace/native/")],
        extensions: [".js", ".elm", ".scss", ".png", ".css", ".woff", ".woff2"]
    },
    module: {
        rules: [
            {
                test: /\.js$/,
                exclude: /node_modules/,
                use: {
                    loader: "babel-loader"
                }
            },
            {
                test: /\.scss$/,
                exclude: [/elm-stuff/],
                loaders: ["style-loader", "css-loader", "sass-loader"]
            },
            {
                test: /\.css$/,
                exclude: [/elm-stuff/],
                loaders: ["style-loader", "css-loader"]
            },
            {
            test: /\.(png|woff|woff2|eot|ttf|svg)$/,
            loader: 'url-loader?limit=100000'
            },
            {
                test: /\.(ttf|eot|svg)(\?v=[0-9]\.[0-9]\.[0-9])?$/,
                exclude: [/elm-stuff/, /node_modules/],
                loader: "file-loader"
            },
            {
                test: /\.(jpe?g|png|gif|svg)$/i,
                loader: "file-loader"
            }
        ]
    }
};

if (MODE === "development") {
    console.log("Building for dev...");
    module.exports = merge(common, {
        plugins: [
            // Suggested for hot-loading
            new webpack.NamedModulesPlugin(),
            // Prevents compilation errors causing the hot loader to lose state
            new webpack.NoEmitOnErrorsPlugin()
        ],
        module: {
            rules: [
                {
                    test: /\.elm$/,
                    exclude: [/elm-stuff/, /node_modules/],
                    use: [
                        { loader: 'elm-hot-webpack-loader' },
                        {
                            loader: "elm-webpack-loader",
                            options: {
                                // add Elm's debug overlay to output
                                debug: true,
                                forceWatch: true
                            }
                        }
                    ]
                }
            ]
        },
        serve: {
            //inline: true,
            stats: "errors-only",
            content: [path.join(__dirname, "src/assets")],
            add: (app, middleware, options) => {
                // routes /xyz -> /index.html
                app.use(convert(proxy('/api', 
			{ target: 'http://localhost:8080',
			  pathRewrite: { '^/api': ''},
				changeOrigin: true })));
                app.use(history());
                // e.g.
		},
            }
        
    });
}

if (MODE === "production") {
    console.log("Building for Production...");
    module.exports = merge(common, {
        plugins: [
            // Delete everything from output directory and report to user
            new CleanWebpackPlugin(["dist"], {
                root: __dirname,
                exclude: [],
                verbose: true,
                dry: false
            }),
            new CopyWebpackPlugin([
                {
                    from: "src/assets"
                }
            ]),
            new MiniCssExtractPlugin({
                // Options similar to the same options in webpackOptions.output
                // both options are optional
                filename: "[name]-[hash].css"
            })
        ],
        module: {
            rules: [
                {
                    test: /\.elm$/,
                    exclude: [/elm-stuff/, /node_modules/],
                    use: [
                        {
                            loader: "elm-webpack-loader",
                            options: {
                                // add Elm's debug overlay to output
                                debug: true,
                                forceWatch: true
                            }
                        }
                    ]
                },
            {
                test: /\.css$/,
                exclude: [/elm-stuff/, /node_modules/],
                loaders: [MiniCssExtractPlugin.loader, "css-loader"]
            },
            {
                test: /\.scss$/,
                exclude: [/elm-stuff/, /node_modules/],
                loaders: [MiniCssExtractPlugin.loader, "css-loader", "sass-loader"]
            }
            ]
        }
    });
}
